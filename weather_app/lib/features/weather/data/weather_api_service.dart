import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio dio;
  WeatherApiService(this.dio);

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
}
