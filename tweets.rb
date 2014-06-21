require 'json'
require 'uri'
require 'base64'
require 'net/http'
require 'dotenv'
require 'pry'

class TwitterAuthentication
	Dotenv.load

	attr_reader :url, :key, :secret

	def initialize(url, key, secret)
		@url = url
		@key = key
		@secret = secret
	end

	def get_bearer_token
		JSON.parse(make_auth_request.body)["access_token"]
	end

	protected

	def uri_encode(url)
		URI.parse(url)
	end

	def base_64_encode_key_and_secret
		auth = "#{uri_encode(key)}:#{uri_encode(secret)}"
    "Basic #{Base64.strict_encode64(auth)}"
	end

	def auth_request_content
    {
			'authorization' => base_64_encode_key_and_secret,
			'content_type' => 'application/x-www-form-urlencoded;charset=UTF-8',
		  'grant_type' => 'grant_type=client_credentials'
	  }
	end

	def create_auth_http_object
		http = Net::HTTP.new(uri_encode(url).host, uri_encode(url).port)
		http.use_ssl = true
		http
	end

	def create_auth_request
    req = Net::HTTP::Post.new(uri_encode(url).path)
		req.add_field('Authorization', auth_request_content['authorization'])
		req.add_field('Content-Type', auth_request_content['content_type'])
		req.body = auth_request_content['grant_type']
		req
	end

	def make_auth_request
		create_auth_http_object.request(create_auth_request)
	end
	 
end

class TwitterQuery
	
	def initialize(base_url, query, parameters)
		@base_url = base_url
		@query = query
		@since_id = 0
		@parameters = parameters
	end

	def get_tweets(bearer_token)
		tweets = []
		until tweets.count >= 1000
			ids = []
			@query_response = JSON.parse(make_query_request(bearer_token).body)
			tweets += @query_response["statuses"]
			tweets.each {|tweet| ids << tweet["id"]}
			@since_id = ids.max
		end
		tweets
	end

	def get_locations
		locations = []
		retweet_locations = []
		get_tweets.each do |tweet|
  		locations << tweet["user"]["location"] if tweet["user"]["location"] != nil
  		retweet_locations << tweet["retweeted_status"]["user"]["location"] if tweet["retweeted"] == true && tweet["retweeted_status"] != nil
		end
		#tweet['retweeted_status']['user']['location'] is the correct path
		all_locations = locations + retweet_locations
	end

	protected

	def uri_encode_query_url
		URI.parse("#{@base_url}#{@query}#{@parameters}#{@since_id}")
	end

	def create_query_http_object
	  query_http = Net::HTTP.new(uri_encode_query_url.host, uri_encode_query_url.port)
	  query_http.use_ssl = true
	  query_http
	end

	def create_query_request(bearer_token)
		query_request = Net::HTTP::Get.new(uri_encode_query_url.path)
		query_request.add_field('Authorization', "Bearer #{bearer_token}")
		query_request
	end

	def make_query_request(bearer_token)
		create_query_http_object.request(create_query_request(bearer_token))
	end
		
end
#CAN MAKE ONE 'ENCODE' METHOD THAT TAKES THE STRING TO ENCODE AND MODULE TO USE
#CAN MAKE ONE METHOD THAT CREATES HTTP OBJECTS OF THE APPROPRIATE TYPE (OPTIONAL HTTP METHOD ARG)
#AND ANOTHER TO ADD THE NEEDED HEADER AND BODY CONTENT
#SHARE THESE METHODS FOR GETTING THE BEARER TOKEN AND THE JSON DATA

bearer_token = TwitterAuthentication.new('https://api.twitter.com/oauth2/token', ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY']).get_bearer_token

query_request = TwitterQuery.new("https://api.twitter.com/1.1/search/tweets.json", "?q=#ruby%20or%20rails", "&count=100&since_id=#{@since_id}")
#&result_type=popular
binding.pry
tweets = query_request.get_tweets(bearer_token)
locations = query_request.get_locations
