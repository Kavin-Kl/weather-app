import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio dio;
  WeatherApiService(this.dio);

  // Existing methods (can keep for now or remove if only using One Call)
  Future<Response> getCurrentWeather(double lat, double lon, String apiKey) {
    return dio.get(
      'https://api.openweathermap.org/data/2.5/weather',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
        'units': 'metric',
      },
    );
  }

  Future<Response> getForecast(double lat, double lon, String apiKey) {
    return dio.get(
      'https://api.openweathermap.org/data/2.5/forecast',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
        'units': 'metric',
      },
    );
  }

  // New method for OpenWeatherMap One Call API
  Future<Response> getOneCallWeather(double lat, double lon, String apiKey) {
    return dio.get(
      'https://api.openweathermap.org/data/2.5/onecall', // Changed to v2.5 endpoint for free tier
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
        'units': 'metric', // or 'imperial'
        'exclude': 'minutely', // Exclude data not needed
      },
    );
  }

  // Method for Air Pollution API
  Future<Response> getAirPollution(double lat, double lon, String apiKey) {
    return dio.get(
      'https://api.openweathermap.org/data/2.5/air_pollution',
      queryParameters: {
        'lat': lat,
        'lon': lon,
        'appid': apiKey,
      },
    );
  }
}
