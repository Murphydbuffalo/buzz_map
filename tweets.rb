require 'json'
require 'uri'
require 'base64'
require 'net/http'
require 'dotenv'
require 'pry'

class TwitterAuthenticationRequest
	Dotenv.load

	attr_reader :http

	def initialize(key, secret)
		@key = key
		@secret = secret
	end

	def uri_encode_key
		URI(@key)
	end

	def uri_encode_secret
		URI(@secret)
	end

	def base_64_encode_key_and_secret
		auth = "#{uri_encode_key}:#{uri_encode_secret}"
    "Basic #{Base64.strict_encode64(auth)}"
	end

	def auth_request_header
    {
			'authorization' => base_64_encode_key_and_secret,
			'content_type' => 'application/x-www-form-urlencoded;charset=UTF-8',
		  'grant_type' => 'grant_type=client_credentials'
	  }
	end

	def auth_request_url
		URI.parse('https://api.twitter.com/oauth2/token')
	end

	def create_auth_http_object
		@http = Net::HTTP.new(auth_request_url.host, auth_request_url.port)
		@http.use_ssl = true
		@http
	end

	def create_auth_request
    req = Net::HTTP::Post.new(auth_request_url.path)
		req.add_field('Authorization', auth_request_header['authorization'])
		req.add_field('Content-Type', auth_request_header['content_type'])
		req.body = auth_request_header['grant_type']
		req
	end

	def make_auth_request
		create_auth_http_object.request(create_auth_request)
	end

	def get_bearer_token
		JSON.parse(make_auth_request.body)["access_token"]
	end
	 
end

class TwitterQuery
	
	def initialize(query, base_url, parameters)
		@base_url = base_url
		@query = query
		@parameters = parameters
		@tweets = []
		@locations = []
		@retweet_locations = []
		@since_id = 0
	end

	def uri_encode_query_url
		URI.parse("#{@base_url}#{@query}#{@parameters}#{@since_id}")
		#Since_id is the lowest tweet id number your query will retrieve.
		#You can set since_id equal to the highest tweet id number you've received.
		#This ensures that you only retrieve new tweets as you make more requests (eg, within the loop below). 
	end

	def create_query_http_object
		@query_http = Net::HTTP.new(uri_encode_query_url.host, uri_encode_query_url.port)
	  @query_http.use_ssl = true
	end

	def create_query_request
		query_request = Net::HTTP::Get.new(uri_encode_query_url.path)
		query_request.add_field('Authorization', "Bearer #{TwitterAuthenticationRequest.bearer_token}")
		query_request
	end

	def get_tweets
		until @tweets.count >= 1000
			ids = []
			query_response = JSON.parse(create_query_http_object.request(@query_http).body)
			@tweets += query_response["statuses"]
			@tweets.each {|tweet| ids << tweet["id"]}
			@since_id = ids.max
		end
	end

	def get_locations
		@tweets.each do |tweet|
  		@locations << tweet["user"]["location"] if tweet["user"]["location"] != nil
  		@retweet_locations << tweet["retweeted_status"]["user"]["location"] if tweet["retweeted"] == true && tweet["retweeted_status"] != nil
		end
		#tweet['retweeted_status']['user']['location'] is the correct path
	end
		
end

api_key = ENV['TWITTER_API_KEY']
api_secret = ENV['TWITTER_SECRET_KEY']

auth_request = TwitterAuthenticationRequest.new(ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY'])
bearer_token = auth_request.get_bearer_token
puts bearer_token

#base_url = "https://api.twitter.com/1.1/search/tweets.json"
#&result_type=popular
#query = "q=#ruby%20or%20rails"
#parameters = "&count=100&since_id=#{count}"

# puts tweets.count
# puts locations.count
# puts retweet_locations.count
# binding.pry
