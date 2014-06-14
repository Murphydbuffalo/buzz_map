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


binding.pry



# requ = RestClient::Resource.new("https://api.twitter.com/oauth2/token")
# response = ''

# options = {}
# options['Authorization'] = "Basic #{authorization}"
# options['Content-Type'] = 'application/x-www-form-urlencoded;charset=UTF-8'

# requ.post('grant_type=client_credentials', options) do |response, request, result|
#     response << "#{CGI::escapeHTML(response.inspect)} >"
#     binding.pry
#     response << "#{CGI::escapeHTML(request.inspect)}<br /><br />"
#     binding.pry
#     response << "#{CGI::escapeHTML(result.inspect)}<br />"
#     binding.pry
# end



# query = "rubyjobORrailsjobORwebdevjob"

# base_url = "https://api.twitter.com/1.1/search/tweets.json?q=#{query}"

# url = URI("#{base_url}#{query}")
# binding.pry
# json_response = Net::HTTP.get(url)
# binding.pry
# parsed_response = JSON.parse(json_response)
# binding.pry
# tweets = parsed_response["statuses"]
# binding.pry

#https://api.twitter.com/1.1/search/tweets.json?q=%40twitterapi
#https://twitter.com/search?f=realtime&q=https%3A%2F%2Fapi.twitter.com%2F1.1%2Fsearch%2Ftweets.json%3Fq%3Drubyjobs&src=typd

