# app/services/weather_service.rb

class WeatherService
  BASE_URL = "http://api.weatherapi.com/v1/forecast.json"
  API_KEY = ENV['WEATHER_API_KEY']
  CACHE_EXPIRATION = 30.minutes

  # Fetches weather data for a city, using the cache if available.
  def self.fetch_weather(city)
    cache_key = cache_key_for(city)
    cached_data = read_from_cache(cache_key)

    return cached_data if cached_data

    response = fetch_from_api(city)
    write_to_cache(cache_key, response) if response["error"].nil?

    response
  end

  private

  # Constructs the cache key.
  def self.cache_key_for(city)
    "weather_#{city.downcase}"
  end

  # Reads data from cache.
  def self.read_from_cache(cache_key)
    cached_data = Rails.cache.read(cache_key)
    if cached_data
      Rails.logger.info("Cache hit for key: #{cache_key}")
      cached_data.merge("from_cache" => true)
    else
      Rails.logger.info("Cache miss for key: #{cache_key}")
      nil
    end
  end

  # Writes data to cache.
  def self.write_to_cache(cache_key, data)
    Rails.cache.write(cache_key, data, expires_in: CACHE_EXPIRATION)
  end

  # Fetches data from the API.
  def self.fetch_from_api(city)
    uri = URI.parse("#{BASE_URL}?key=#{API_KEY}&q=#{URI.encode_www_form_component(city)}&days=5&aqi=no&alerts=no")
    response = Net::HTTP.get(uri)
    parse_response(response)
  rescue StandardError => e
    handle_error(e, city)
  end

  # Parses the API response.
  def self.parse_response(response)
    JSON.parse(response).merge("from_cache" => false)
  rescue JSON::ParserError => e
    handle_error(e)
  end

  # Handles errors during the request/response cycle.
  def self.handle_error(exception, city = nil)
    Rails.logger.error("WeatherService Error for city '#{city}': #{exception.message}")
    { "error" => "Unable to fetch weather data", "from_cache" => false }
  end
end
