require 'sinatra'
# require 'pry'
require 'json'
require 'uri'
require 'base64'
require 'net/http'
require 'dotenv'

require_relative('google_maps.rb')
require_relative('tweets.rb')

get '/' do
  erb :'index.html'
end

post '/' do
  @search_term = params[:query]
  if @search_term != nil
    coordinates = twitter_data[:tweet_coordinates]
  end

  google_client = GoogleMaps.new(coordinates)
  counties = google_client.create_counties_array
  @counties = counties

  erb :'index.html'
end
