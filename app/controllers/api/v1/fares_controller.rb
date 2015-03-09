require 'redis'
require 'uri'
require 'google_directions'

require_relative '../../../../lib/scrape'

class Api::V1::FaresController < ApplicationController
  respond_to :json

  # Send lat/lng origin and lat/lng destination to retrieve fare information
  def create
    origin = params[:fare][:origin]
    destination = params[:fare][:destination]

  	uber = calculate_uber(origin, destination)
    lyft = calculate_lyft(origin, destination)

    if uber and lyft
      render json: [
        {
          company: 'uber', 
          id: 1, 
          price: uber, 
          image: '/assets/uber.png'
        },
        {
          company: 'lyft',
          id: 2,
          price: lyft,
          image: '/assets/lyft.png'
        }], status: 200
    else
      render status: 500
    end

  end

private
    BoundingBox = Struct.new(:east_lon, :west_lon, :north_lat, :south_lat)
    Point = Struct.new(:lat, :lon)

    def address_params
      params.require(:fare).permit(
        :origin => [:latitude, :longitude, :address, :state, :country],
        :destination => [:latitude, :longitude, :address, :state, :country]
      )
    end

    ####################################################################################################
    # World's Worst GIS (TM)
    # All but a few of Lyft's bounding boxes are rectangular. In lieu of using PostGIS, just use this:
    # For any rectangular bounding box, a point is WITHIN if and only if:
    # Its longitude is greater than the west longitude of bouding box but less than the east longitude
    # of the bounding box and if its latitude is less than the north latitude of the bounding box but 
    # greater than the southern latitude.
    #
    # TODO: Add PostGIS ActiveRecord module and use a real bounding box algorithm and move off Redis, or
    # wait for Lyft to release a public API like Uber
    ####################################################################################################
    def in_bounding_box?(point, box)
      if point.lon > box.west_lon and point.lon < box.east_lon and point.lat < box.north_lat and point.lat > box.south_lat
        return true
      else
        return false 
      end
    end

    # Ping Uber's public API to retrieve fare data
    def calculate_uber(origin, destination)
      begin
        origin_lat = origin['latitude']
        origin_lon = origin['longitude']

        destination_lat = destination['latitude']
        destination_lon = destination['longitude']

        # Vehicle IDs
        vids = '&vids%5B%5D=123&vids%5B%5D=1272&vids%5B%5D=2285'

        # URL parameters
        base_url = 'https://www.uber.com/fares/latLngEstimate?'
        start_lat = 'start_latitude=' + origin_lat.to_s
        start_lon = '&start_longitude=' + origin_lon.to_s
        end_lat = '&end_latitude=' + destination_lat.to_s
        end_lon = '&end_longitude=' + destination_lon.to_s

        fares = get_site_data(base_url + start_lat + start_lon + end_lat + end_lon + vids, true)

        return fares['estimates'][0]['fare_string']
      rescue
        raise 'Could not calculate Uber fare'
      end
    end

    def calculate_lyft(origin, destination)
      begin
        unless Rails.env.production?
          redis = Redis.new
        else
          uri = URI.parse(ENV["REDISCLOUD_URL"])
          redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
        end

        directions = GoogleDirections.new(origin['address'], destination['address'])

        time = directions.drive_time_in_minutes
        miles = directions.distance_in_miles
        origin_lat = origin['latitude']
        origin_lon = origin['longitude']
        fare = nil

        keys = redis.keys(pattern='lyft_*')
        keys.each do |key|
          data = redis.hgetall(key)
          point = Point.new(origin_lat.to_f, origin_lon.to_f)
          box = BoundingBox.new(data['east_lon'].to_f, data['west_lon'].to_f, data['north_lat'].to_f, data['south_lat'].to_f)
          if in_bounding_box?(point, box)
            fare = data['trust_safety'].to_f + data['base_charge'].to_f + ((data['cost_per_mile'].to_f * miles.to_f) + (data['cost_per_minute'].to_f * time))
            if fare.to_f < data['cost_minimum'].to_f
              fare = data['cost_minimum'].to_f
            end
            break
          end
        end
        return '$' + fare.round(2).to_s
      rescue
        raise 'Could not calculate Lyft fare'
      end
    end
end