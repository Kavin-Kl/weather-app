import '../data/weather_api_service.dart';

abstract class WeatherRepository {
  Future<Map<String, dynamic>> getCurrentWeather(
      double lat, double lon, String timezone);
  Future<Map<String, dynamic>> getForecast(
      double lat, double lon, String timezone);
  Future<Map<String, dynamic>> getDetailedWeather(
      double lat, double lon, String timezone);
}

class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherApiService apiService;
  WeatherRepositoryImpl(this.apiService);

  @override
  Future<Map<String, dynamic>> getCurrentWeather(
      double lat, double lon, String timezone) async {
    final response = await apiService.getCurrentWeather(lat, lon, timezone);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getForecast(
      double lat, double lon, String timezone) async {
    final response = await apiService.getForecast(lat, lon, timezone);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> getDetailedWeather(
      double lat, double lon, String timezone) async {
    final response = await apiService.getDetailedWeather(lat, lon, timezone);
    return response.data;
  }
}
