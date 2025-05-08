# app/services/weather_service.rb

# Fetches and caches weather data from an external API.
class WeatherService
  BASE_URL = "http://api.weatherapi.com/v1/forecast.json"
  API_KEY = ENV['WEATHER_API_KEY']
  CACHE_EXPIRATION = 30.minutes

  # Fetches weather data for a city, using the cache if available.
  def self.fetch_weather(city)
    cache_key = "weather_#{city.downcase}"
    cached_data = Rails.cache.read(cache_key)
    return cached_data if cached_data

    response = request_weather_data(city)
    Rails.cache.write(cache_key, response, expires_in: CACHE_EXPIRATION)
    response
  end

  private

  # Makes the API request to fetch weather data.
  def self.request_weather_data(city)
    uri = URI("#{BASE_URL}?key=#{API_KEY}&q=#{city}&days=5&aqi=no&alerts=no")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue JSON::ParserError, StandardError => e
    Rails.logger.error("WeatherService Error: #{e.message}")
    { "error" => "Unable to fetch weather data" }
  end
end