require 'redis'
require 'json'
require 'nokogiri'
require 'uri'
require_relative '../scrape'


def scrape_lyft()
  unless Rails.env.production?
    redis = Redis.new
  else
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  data = get_site_data('https://www.lyft.com/api/city', true)
  keys = redis.keys(pattern='lyft_*')
  keys.each do |key|
    city = key.sub 'lyft_', ''
    fees = data[city]['pricing'][0]['fields']
    redis.hmset(key, 'trust_safety', fees['Trust & Safety Fee'],\
      'base_charge', fees['baseCharge'],\
      'cancel_penalty', fees['cancelPenalty'],\
      'cost_minimum', fees['costMinimum'],\
      'cost_per_mile', fees['costPerMile'],\
      'cost_per_minute', fees['costPerMinute'])
  end
end


def scrape_uber()
  unless Rails.env.production?
    redis = Redis.new
  else
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end

  keys = redis.keys(pattern='uber_*')
  keys.each do |key|
    city = key.sub 'uber_', ''
    data = get_site_data('https://www.uber.com/cities/' + city, false)
    html = Nokogiri::HTML.parse(data).css('body').first
    fare_block = html.at('.js-breakdown').to_html
    fares = fare_block.scan(/\$\s*[0-9,]+(?:\s*\.\s*\d{2})?/)

    begin
      redis.hmset(key, 'base_charge', fares[0],\
        'cost_per_minute', fares[1],\
        'cost_per_mile', fares[2],\
        'trust_safety', fares[3],\
        'trust_safety', fares[4],\
        'cancel_penalty', fares[5])
    rescue
    end
  end
end


namespace :fares do
  desc "Generate Uber fare data"
  task :uber do
    unless Rails.env.production?
      redis = Redis.new
    else
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end

    cities = get_site_data('https://www.uber.com/cities/?limit=999', true)
    cities.each do |city|
      key = 'uber_' + city['slug']
      redis.hmset(key, 'url', city['slug'], 'name', city['localized_display_name'])
    end
    scrape_uber()
  end

  desc "Generate Lyft fare data"
  task :lyft do
    unless Rails.env.production?
      redis = Redis.new
    else
      uri = URI.parse(ENV["REDISCLOUD_URL"])
      redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end

    data = get_site_data('https://www.lyft.com/api/city', true)

    data.each do |city, fare|
      key = 'lyft_' + city
      coords = fare['serviceArea']
      redis.hmset(key, 
       'city', city,
       'east_lon', coords['eastLng'],
       'west_lon', coords['westLng'],
       'north_lat', coords['northLat'],
       'south_lat', coords['southLat']
      )
    end
    scrape_lyft()
  end
end
