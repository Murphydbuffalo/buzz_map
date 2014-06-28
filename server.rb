require 'sinatra'
require 'pg'
require 'pry'
require 'json'
require 'uri'
require 'net/http'
require 'dotenv'

Dotenv.load

def get_counties_from_coordinates(lat,long)
  api_key = ENV['MAPS_ACCESS_KEY']

  api_url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{long}&result_type=administrative_area_level_2&key=#{api_key}"
  get_url = URI.parse(api_url)

  get_http = Net::HTTP.new(get_url.host, get_url.port)
  get_http.use_ssl = true

  get_request = Net::HTTP::Get.new(get_url)
  get_response = get_http.request(get_request)

  parsed_get_response = JSON.parse(get_response.body)
end

def create_counties_array
  counties = []

  #replace coordinates_array with live Twitter data
  coordinates_array = [[-7.88136844, 42.32077233],
   [-85.9775004, 39.7623115],
   [-118.10745395, 33.97381535],
   [-93.25061711, 31.06719856],
   [-85.9673088, 31.8041108]]

  coordinates_array.each do |county_coordinates|
    lat = county_coordinates[1].to_s
    long = county_coordinates[0].to_s
    data = get_counties_from_coordinates(lat, long)

      if data["status"] != "ZERO_RESULTS"
        county = data["results"][0]["formatted_address"]
        county_array = county.gsub(',', '').split
        county_array.pop
        county_array.delete_at(-2)
        formatted_county_name = county_array.join(' ')
        formatted_county_name.insert(-4, ',')
        counties.push(formatted_county_name)
      end
    end
  counties
end

get '/' do
  @counties = create_counties_array
  erb :'index.html'
end
