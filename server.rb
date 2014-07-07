require 'sinatra'
require 'pry'
require 'json'
require 'uri'
require 'base64'
require 'net/http'
require 'dotenv' if ENV['RACK_ENV'] != 'production'

require_relative('google_maps.rb')
require_relative('tweets.rb')

get '/' do
  erb :'index.html'
end

post '/' do
  @search_term = params[:query]
  if @search_term != nil
    google_client = GoogleMaps.new(twitter_data)
    counties = google_client.create_counties_array
    @counties = counties
  end

  erb :'index.html'
end
