class GoogleMaps
  Dotenv.load if ENV['RACK_ENV'] != 'production'

  attr_reader :all_tweet_locations

  def initialize(all_tweet_locations)
    @all_tweet_locations = all_tweet_locations
  end

  def create_counties_array
    counties = []

    all_tweet_locations.each do |tweet_location|
      if tweet_location.is_a?(Array)
        lat = tweet_location[1].to_s
        long = tweet_location[0].to_s
        results = "latlng=#{lat},#{long}"
      else
        tweet_location.gsub!(/[^0-9a-z,]/i, '')
        results = "address=#{tweet_location}"
      end

      all_county_data = get_county_info_from_locations(results)

      if all_county_data["status"] != "ZERO_RESULTS" && all_county_data["results"][0]["formatted_address"].split.pop == 'USA'
        formatted_county_name = format_county_name(all_county_data)
        counties.push(formatted_county_name) if formatted_county_name != nil
      end
    end
    puts counties
    counties
  end

  def get_county_info_from_locations(results)
    api_key = ENV['MAPS_ACCESS_KEY']
    api_url = "https://maps.googleapis.com/maps/api/geocode/json?#{results}&result_type=administrative_area_level_2&key=#{api_key}"
    get_url = URI.parse(api_url)
    get_http = Net::HTTP.new(get_url.host, get_url.port)
    get_http.use_ssl = true
    get_request = Net::HTTP::Get.new(get_url)
    get_response = get_http.request(get_request)
    parsed_get_response = JSON.parse(get_response.body)
  end

  def format_county_name(all_county_data)
    if all_county_data["results"][0]["address_components"][0]["long_name"].include?('County')
      county = all_county_data["results"][0]["formatted_address"] 
      county_word_array = county.gsub(',', '').split
      county_word_array.pop
      county_word_array.delete_at(-2)
      formatted_county_name = county_word_array.join(' ')
      formatted_county_name.insert(-4, ',')
    end
  end
end
