require 'json'
require 'uri'
require 'base64'
require 'net/http'
require 'dotenv'
require 'rest_client'
require 'cgi'
require 'pry'

Dotenv.load

api_key = ENV['TWITTER_API_KEY']
api_secret = ENV['TWITTER_SECRET_KEY']

api_key_url = URI(api_key)
api_secret_url = URI(api_secret)

app_only_auth = api_key_url.to_s + ":" + api_secret_url.to_s

authorization = "Basic #{Base64.strict_encode64(app_only_auth)}"

url = URI.parse('https://api.twitter.com/oauth2/token')

content_type = 'application/x-www-form-urlencoded;charset=UTF-8'

grant_type = 'grant_type=client_credentials'

header = {
	'authorization' => authorization,
	'content_type' => content_type,
  'grant_type' => grant_type
  }

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

req = Net::HTTP::Post.new(url.path)
req.add_field("Authorization", authorization)
req.add_field("Content-Type", content_type)
req.body = grant_type
response = http.request(req)

parsed_response = JSON.parse(response.body)
bearer_token = parsed_response["access_token"]

query = "ruby%20or%20rails"

count = 0

api_url = "https://api.twitter.com/1.1/search/tweets.json?q=#{query}&count=100$since_id=#{count}"

get_url = URI.parse(api_url)

get_http = Net::HTTP.new(get_url.host, get_url.port)
get_http.use_ssl = true

get_request = Net::HTTP::Get.new(get_url)
get_request.add_field('Authorization', "Bearer #{bearer_token}")

tweets = []
coordinates = []
ids = []

until tweets.count >= 1000
	ids = []
	
	get_response = http.request(get_request)
	parsed_get_response = JSON.parse(get_response.body)
	tweets += parsed_get_response["statuses"]
	
	tweets.each {|tweet| ids << tweet["id"]}
	count = ids.max
end

tweets.each do |tweet|
    coordinates << tweet["coordinates"] if tweet["coordinates"] != nil
    coordinates << tweet["retweeted_status"]["coordinates"] if tweet["retweeted"] != false 
end

puts tweets.count

puts coordinates.count

#binding.pry
