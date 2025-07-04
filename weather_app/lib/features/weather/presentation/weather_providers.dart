import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weather_api_service.dart';
import '../domain/weather_repository.dart';
import '../../../core/providers.dart';

const String openWeatherApiKey =
    'YOUR_OPENWEATHER_API_KEY'; // Replace with your API key

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return WeatherApiService(dio);
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiService = ref.watch(weatherApiServiceProvider);
  return WeatherRepositoryImpl(apiService, openWeatherApiKey);
});
