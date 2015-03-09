require 'curb'
require 'json'

def get_site_data(url, json)
  c = Curl::Easy.new(url) do |curl| 
    curl.headers["X-Requested-With"] = "XMLHttpRequest"
    curl.verbose = true
  end

  c.perform

  if json
    return JSON.parse(c.body_str)
  else 
    return c.body_str
  end
end