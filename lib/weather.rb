require 'httparty'
require 'json'

class Weather
  WeatherData = Struct.new(:temperature, :conditions, :wind_speed, :humidity, :pressure, keyword_init: true)

  def self.conditions(lat: 51.597146, lon: -0.147504)
    url = "https://api.darksky.net/forecast/#{ENV['DARKSKY_API_KEY']}/#{lat},#{lon}"
    raw_response = HTTParty.get(url)
    response = JSON.parse(raw_response.body)
    summary = response['currently']['summary'].downcase.capitalize
    fahrenheit = response['currently']['temperature'].to_f
    celcius = "#{((fahrenheit - 32) * 5) / 9}.#{((fahrenheit - 32) * 5) % 9}".to_f
    temperature = "#{celcius.round(1)}°C"
    humidity = "#{(response['currently']['humidity'].to_f * 100).round}%"
    pressure = "#{response['currently']['pressure'].to_f.round} mb"
    wind_speed = "#{response['currently']['windSpeed'].to_f.round} mph"
    WeatherData.new(
      conditions: summary,
      temperature: temperature,
      humidity: humidity,
      pressure: pressure,
      wind_speed: wind_speed
    )
  end
end
