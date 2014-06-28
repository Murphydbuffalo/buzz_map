class TwitterRequest
	Dotenv.load

	attr_accessor :url
	attr_reader :key, :secret, :headers, :body

	def initialize(url='')
		@url = URI.parse(url)
		@key = URI.parse(ENV['TWITTER_API_KEY'])
		@secret = URI.parse(ENV['TWITTER_SECRET_KEY'])
	end

	def base_64_encode_key_and_secret
    "Basic #{Base64.strict_encode64("#{key}:#{secret}")}"
	end

	def add_request_content(headers, body)
    @headers = headers
    @body = body
	end

	def bearer_token
		JSON.parse(make_request('Post').body)["access_token"]
	end

	def get_tweets(query_duration_in_seconds, query)
		@since_id = 0
		tweets = []
    count = 100
		until count < 20
			ids = []
			self.url = URI.parse("https://api.twitter.com/1.1/search/tweets.json?q=#{query}&count=100&since_id=#{@since_id}")
			query_response = JSON.parse(make_request('Get').body)
			tweets += query_response["statuses"]
      count = query_response["statuses"].count
			tweets.each { |tweet| ids << tweet["id"] }
			@since_id = ids.max
		end
		tweets.uniq
	end

	def get_user_locations(tweets)
		locations = []
		tweets.each do |tweet|
  		locations << tweet["user"]["location"] if tweet["user"]["location"]
		end
		locations
	end

	def get_retweet_user_locations(tweets)
    retweet_locations = []
    tweets.each do |tweet|
  		retweet_locations << tweet["retweeted_status"]["user"]["location"] if tweet["retweeted_status"]
		end
		retweet_locations
	end

	def get_tweet_coordinates(tweets)
		coordinates = []
		tweets.each do |tweet|
  		coordinates << tweet["coordinates"]["coordinates"] if tweet["coordinates"]
		end
		coordinates
	end

		protected

	def create_http_object
		http = Net::HTTP.new(url.host, url.port)
		http.use_ssl = true
		http
	end

	def create_request(type)
		req = ''
		type.downcase.start_with?('p') ? req = Net::HTTP::Post.new(url.path) : req = Net::HTTP::Get.new(url)
		headers.each { |k, v| req.add_field(k, v) }
		req.body = body
		req
	end

	def make_request(type)
		create_http_object.request(create_request(type))
	end

end

def twitter_authorization
   # POST request, sends encoded key & secret in exchange for a bearer token
    bearer_token_request = TwitterRequest.new('https://api.twitter.com/oauth2/token')
    auth = bearer_token_request.base_64_encode_key_and_secret
    bearer_token_request.add_request_content(
        {
          'authorization' => auth, 
          'content_type' => 'application/x-www-form-urlencoded;charset=UTF-8'
        },
        'grant_type=client_credentials'
      )
    bearer_token_request.bearer_token
end

def twitter_query_request
  # GET request sent with bearer token in header, retrieves tweets
  query_request = TwitterRequest.new
  query_request.add_request_content({'Authorization' => "Bearer #{twitter_authorization}"}, '')
  query_request
end

def tweets
  twitter_query_request.get_tweets(10, @search_term)
end

def twitter_data
  {
    :user_locations => twitter_query_request.get_user_locations(tweets),
    :retweet_user_locations => twitter_query_request.get_retweet_user_locations(tweets),
    :tweet_coordinates => twitter_query_request.get_tweet_coordinates(tweets)
  }
end
