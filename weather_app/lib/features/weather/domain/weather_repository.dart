import '../data/weather_api_service.dart';

abstract class WeatherRepository {
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon);
  Future<Map<String, dynamic>> getForecast(double lat, double lon);
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;
  final String apiKey;
  WeatherRepositoryImpl(this.apiService, this.apiKey);

  @override
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    final response = await apiService.getCurrentWeather(lat, lon, apiKey);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getForecast(double lat, double lon) async {
    final response = await apiService.getForecast(lat, lon, apiKey);
    return response.data;
  }
}
