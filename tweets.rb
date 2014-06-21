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
		@url = url
		@key = key
		@secret = secret
		@since_id = 0
	end

	def base_64_encode_key_and_secret
    "Basic #{Base64.strict_encode64("#{uri_encode(key)}:#{uri_encode(secret)}")}"
	end

	def add_request_content(headers, body)
    @headers = headers
    @body = body
	end

	def get_bearer_token(request_type)
		JSON.parse(make_request(request_type).body)["access_token"]
	end

	def get_tweets(bearer_token)
		tweets = []
		until tweets.count >= 1000
			ids = []
			@query_response = JSON.parse(make_request('Get').body)
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

	def uri_encode(url)
		URI.parse(url)
	end
	
	def create_http_object
		http = Net::HTTP.new(uri_encode(url).host, uri_encode(url).port)
		http.use_ssl = true
		http
	end

	def create_request(type)
		type.downcase.start_with?('p') ? req = Net::HTTP::Post.new(uri_encode(url).path) : req = Net::HTTP::Get.new(uri_encode(url).path)
		headers.each {|k, v| req.add_field(k, v) } 
		req.body = body
		req
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

bearer_token = bearer_token_request.get_bearer_token('Post')

query_request = TwitterRequest.new("https://api.twitter.com/1.1/search/tweets.json?q=#ruby&count=100", ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY'])
query_request.add_request_content({'Authorization' => "Bearer #{bearer_token}"}, '')
#&since_id=#{@since_id} &result_type=popular
binding.pry
tweets = query_request.get_tweets
locations = query_request.get_locations
binding.pry