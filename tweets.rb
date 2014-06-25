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
    until tweets.count >= 100
      ids = []
      query_response = JSON.parse(make_request('Get').body)
      tweets += query_response["statuses"]
      tweets.each {|tweet| ids << tweet["id"]}
      @since_id = ids.max
    end
    tweets
  end

  def get_user_locations(tweets)
    locations = []
    tweets.each do |tweet|
      locations << tweet["user"]["location"] if tweet["user"]["location"] != nil
    end
    locations #tweet['retweeted_status']['user']['location'] is the correct path
  end

  def get_retweet_user_locations(tweets)
    retweet_locations = []
    tweets.each do |tweet|
      retweet_locations << tweet["retweeted_status"]["user"]["location"] if tweet["retweeted_status"] != nil
    end
    retweet_locations
  end

  def get_tweet_coordinates(tweets)
    coordinates = []
    tweets.each do |tweet|
      coordinates << tweet["coordinates"] if tweet["coordinates"] != nil
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
    headers.each {|k, v| req.add_field(k, v) }
    req.body = body
    req
  end

  def make_request(type)
    create_http_object.request(create_request(type))
  end

end
# POST request, sends encoded key & secret in exchange for a bearer token

bearer_token_request = TwitterRequest.new('https://api.twitter.com/oauth2/token', ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY'])
auth = bearer_token_request.base_64_encode_key_and_secret
bearer_token_request.add_request_content(
  {'authorization' => auth, 'content_type' => 'application/x-www-form-urlencoded;charset=UTF-8'},
  'grant_type=client_credentials')

bearer_token = bearer_token_request.get_bearer_token

#=======================================================================

# GET request sent with bearer token in header, retrieves tweets

query_request = TwitterRequest.new("https://api.twitter.com/1.1/search/tweets.json?q=ruby&count=100&since_id=#{@since_id}", ENV['TWITTER_API_KEY'], ENV['TWITTER_SECRET_KEY'])
#&result_type=popular -> Usually no retweets or location results ...not many popular tweets with 'ruby'?
query_request.add_request_content({'Authorization' => "Bearer #{bearer_token}"}, '')
tweets = query_request.get_tweets
user_locations = query_request.get_user_locations(tweets)
retweet_user_locations = query_request.get_retweet_user_locations(tweets)
tweet_coordinates = query_request.get_tweet_coordinates(tweets)

#=======================================================================

puts tweets.count
puts user_locations.count
puts retweet_user_locations.count
puts tweet_coordinates.count
binding.pry
