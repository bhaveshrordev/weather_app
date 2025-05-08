require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  let(:city) { "Indore" }
  let(:cache_key) { "weather_#{city.downcase}" }
  let(:api_response) do
    {
      "location" => { "name" => "Indore", "region" => "Madhya Pradesh" },
      "current" => {
        "temp_c" => 32.0,
        "condition" => { "text" => "Sunny" },
        "humidity" => 50,
        "wind_kph" => 15
      },
      "from_cache" => false
    }
  end

  before do
    allow(Net::HTTP).to receive(:get).and_return(api_response.to_json)
  end

  after do
    Rails.cache.clear
  end

  context "when data is not cached" do
    it "fetches data from the API and caches it" do
      expect(Rails.cache.read(cache_key)).to be_nil

      result = WeatherService.fetch_weather(city)

      expect(result["location"]["name"]).to eq("Indore")
      expect(result["from_cache"]).to eq(false)
      expect(Rails.cache.read(cache_key)).to be_present
    end
  end

  context "when data is cached" do
    before do
      Rails.cache.write(cache_key, api_response.merge("from_cache" => true))
    end

    it "returns the cached data" do
      result = WeatherService.fetch_weather(city)

      expect(result["from_cache"]).to eq(true)
      expect(result["location"]["name"]).to eq("Indore")
      expect(result["current"]["temp_c"]).to eq(32.0)
    end
  end

  context "when API request fails" do
    before do
      allow(Net::HTTP).to receive(:get).and_raise(StandardError.new("API error"))
    end

    it "returns an error message" do
      result = WeatherService.fetch_weather(city)

      expect(result["error"]).to eq("Unable to fetch weather data")
    end
  end

  context "when cache expiration occurs" do
    before do
      Rails.cache.write(cache_key, api_response.merge("from_cache" => true), expires_in: 1.second)
      sleep 2
    end

    it "fetches new data after cache expires" do
      expect(Rails.cache.read(cache_key)).to be_nil

      result = WeatherService.fetch_weather(city)

      expect(result["from_cache"]).to eq(false)
      expect(Rails.cache.read(cache_key)).to be_present
    end
  end
end
