require 'sinatra'
require 'pg'

require 'pry'
require 'json'
require 'uri'
require 'net/http'

def encode_url(lat,long)
  api_url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{long}&result_type=administrative_area_level_1&key=AIzaSyBh0PwMktnnDgOYyyY993LnXcUnv-D6Zcg"
  get_url = URI.parse(api_url)

  get_http = Net::HTTP.new(get_url.host, get_url.port)
  get_http.use_ssl = true

  get_request = Net::HTTP::Get.new(get_url)
  get_response = get_http.request(get_request)

  parsed_get_response = JSON.parse(get_response.body)

end

def get_counties

  counties = []

  coordinates_array = [[42.3581, 71.0636], [37.7833, 122.4167], [45.5200, 122.6819]]

  coordinates_array.each do |county_coordinates|
    lat = county_coordinates[0].to_s
    long = county_coordinates[1].to_s

    data = encode_url(lat, long)

    county = data["results"][0]["formatted_address"].split

    delete_words = ['County,', 'USA']
    county = county.delete_if {|x| delete_words.include?(x)}.join(' ').gsub(',', '').split
    county[-2] = county[-2] + ","
    county = county.join(' ').to_s

    counties.push(county)
    binding.pry
  end

  counties
  binding.pry

end

get '/' do

  @counties = get_counties

  @test = 'testing!'

  erb :'index.html'
end

