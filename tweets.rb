require 'json'
require 'uri'
require 'base64'
require 'net/http'
require 'dotenv'
require 'pry'

class TwitterRequest
	Dotenv.load

	attr_reader :url, :key, :secret, :headers, :body

	def initialize(url, key, secret)
		@url = URI.parse(url)
		@key = URI.parse(key)
		@secret = URI.parse(secret)
		@since_id = 0
	end

	def base_64_encode_key_and_secret
    "Basic #{Base64.strict_encode64("#{key}:#{secret}")}"
	end

	def add_request_content(headers, body)
    @headers = headers
    @body = body
	end

	def get_bearer_token
		JSON.parse(make_request('Post').body)["access_token"]
	end

	def get_tweets
		tweets = []
		until tweets.count >= 1000
			ids = []
			@query_response = JSON.parse(make_request('Get').body)
			binding.pry
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
	
	def create_http_object
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http
	end

	def create_request(type)
		@req = ''
		type.downcase.start_with?('p') ? @req = Net::HTTP::Post.new(url.path) : @req = Net::HTTP::Get.new(url.path)
		headers.each {|k, v| @req.add_field(k, v) } 
		@req.body = body
		@req
	end

	def make_request(type)
		create_http_object.request(create_request(type))
	end
	 
end

bearer_token_request = TwitterRequest.new('https://api.twitter.com/oauth2/token', ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY'])
auth = bearer_token_request.base_64_encode_key_and_secret
bearer_token_request.add_request_content(
	{'authorization' => auth, 'content_type' => 'application/x-www-form-urlencoded;charset=UTF-8'},
	'grant_type=client_credentials')

bearer_token = bearer_token_request.get_bearer_token

query_request = TwitterRequest.new("https://api.twitter.com/1.1/search/tweets.json?q=ruby&count=100", ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY'])
#&since_id=#{@since_id} &result_type=popular
query_request.add_request_content({'Authorization' => "Bearer #{bearer_token}"}, '')
binding.pry
tweets = query_request.get_tweets
locations = query_request.get_locations
binding.pry