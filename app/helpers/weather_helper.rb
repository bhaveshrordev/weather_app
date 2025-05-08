module WeatherHelper

	# Formats the temperature to display both Celsius and Fahrenheit
  def format_temperature(temp_c, temp_f)
    "#{temp_c}°C / #{temp_f}°F"
  end

  # Displays the data source (Cache or API)
  def weather_data_source(from_cache)
    from_cache ? "Data fetched from cache." : "Data fetched from the API."
  end

  # Formats the date for the forecast
  def formatted_date(date)
    Date.parse(date).strftime("%A, %B %d, %Y")
  end
end
