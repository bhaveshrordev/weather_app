class WeatherController < ApplicationController
  
  # Handles the main weather display page.
  def index
    # Get the requested city from the URL parameters.
    city = params[:city]

    if city.present?
      # Use the WeatherService to get the weather data for the given city.
      @weather_data = WeatherService.fetch_weather(city)
    else
      # If no city is provided, set an error message to display in the view.
      @weather_data = { "error" => "City parameter is required" }
    end
  end
end