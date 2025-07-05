import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/weather_api_service.dart';
import '../domain/weather_repository.dart';
import '../../../core/providers.dart';
import '../../../core/geocoding_service.dart';

final weatherApiServiceProvider = Provider<WeatherApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return WeatherApiService(dio);
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  final apiService = ref.watch(weatherApiServiceProvider);
  return WeatherRepositoryImpl(apiService);
});

final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final dio = ref.watch(dioProvider);
  return GeocodingService(dio);
});
