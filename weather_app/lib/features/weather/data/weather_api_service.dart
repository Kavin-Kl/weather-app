import 'package:dio/dio.dart';

class WeatherApiService {
  final Dio dio;
  WeatherApiService(this.dio);

  // Open-Meteo: Current Weather
  Future<Response> getCurrentWeather(double lat, double lon, String timezone) {
    return dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,cloud_cover,surface_pressure,wind_speed_10m',
        'timezone': timezone,
      },
    );
  }

  // Open-Meteo: Hourly Forecast
  Future<Response> getForecast(double lat, double lon, String timezone) {
    return dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'hourly':
            'temperature_2m,relative_humidity_2m,dew_point_2m,apparent_temperature,precipitation_probability,precipitation,weather_code,cloud_cover,temperature_80m,wind_speed_80m',
        'timezone': timezone,
      },
    );
  }

  // Open-Meteo: Daily (7-day) Forecast
  Future<Response> getDetailedWeather(double lat, double lon, String timezone) {
    return dio.get(
      'https://api.open-meteo.com/v1/forecast',
      queryParameters: {
        'latitude': lat,
        'longitude': lon,
        'daily':
            'temperature_2m_min,temperature_2m_max,weather_code,precipitation_sum,sunrise,sunset,uv_index_max,apparent_temperature_mean,temperature_2m_mean',
        'timezone': timezone,
      },
    );
  }
}
