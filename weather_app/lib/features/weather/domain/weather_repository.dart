import '../data/weather_api_service.dart';

abstract class WeatherRepository {
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon);
  Future<Map<String, dynamic>> getForecast(double lat, double lon);
  Future<Map<String, dynamic>> getDetailedWeather(double lat, double lon);
  Future<Map<String, dynamic>> getAirPollution(double lat, double lon);
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

  @override
  Future<Map<String, dynamic>> getDetailedWeather(
      double lat, double lon) async {
    try {
      final response = await apiService.getOneCallWeather(lat, lon, apiKey);
      return response.data;
    } catch (e) {
      // If One Call fails (likely 401), fallback to forecast data for hourly
      final forecast = await getForecast(lat, lon);
      // Map forecast list to a structure similar to One Call's hourly
      final hourly = (forecast['list'] as List?)?.map((item) {
        return {
          'dt': item['dt'],
          'temp': item['main']?['temp'],
          'weather': item['weather'],
        };
      }).toList();
      // Use current weather for 'current'
      final current = await getCurrentWeather(lat, lon);
      return {
        'current': {
          'temp': current['main']?['temp'],
          'weather': current['weather'],
          'temp_min': current['main']?['temp_min'],
          'temp_max': current['main']?['temp_max'],
        },
        'hourly': hourly ?? [],
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getAirPollution(double lat, double lon) async {
    final response = await apiService.getAirPollution(lat, lon, apiKey);
    return response.data;
  }
}
