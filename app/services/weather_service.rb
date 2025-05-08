# app/services/weather_service.rb

class WeatherService
  BASE_URL = "http://api.weatherapi.com/v1/forecast.json"
  API_KEY = ENV['WEATHER_API_KEY']
  CACHE_EXPIRATION = 30.minutes

  # Fetches weather data for a city, using the cache if available.
  def self.fetch_weather(city)
    cache_key = "weather_#{city.downcase}"
    cached_data = Rails.cache.read(cache_key)

    # If data exists in cache, return it with a flag indicating it came from cache
    if cached_data
      cached_data.merge("from_cache" => true)
    else
      # If no cached data, fetch fresh data from API
      response = request_weather_data(city)
      Rails.cache.write(cache_key, response, expires_in: CACHE_EXPIRATION)
      response.merge("from_cache" => false)
    end
  end

  private

  # Makes the API request to fetch weather data.
  def self.request_weather_data(city)
    uri = URI.parse("#{BASE_URL}?key=#{API_KEY}&q=#{URI.encode_www_form_component(city)}&days=5&aqi=no&alerts=no")
    response = Net::HTTP.get(uri)

    # Check if response is successful
    if response.present?
      parsed_response = JSON.parse(response)
      return parsed_response
    else
      Rails.logger.error("WeatherService Error: Empty or nil response for city #{city}")
      return { "error" => "Unable to fetch weather data" }
    end
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error("WeatherService Error: #{e.message}")
    { "error" => "Unable to fetch weather data" }
  end
end

