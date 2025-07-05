import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_state.dart';
import 'weather_providers.dart';
import '../../../core/location_service.dart';
import '../../../core/geocoding_service.dart';

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this.ref) : super(const WeatherState());
  final Ref ref;

  Future<void> fetchWeatherForCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      final repo = ref.read(weatherRepositoryProvider);
      final geocodingService = ref.read(geocodingServiceProvider);
      const timezone = 'auto'; // Or get from user selection

      print(
          'Fetching weather for: lat=${position.latitude}, lon=${position.longitude}, timezone=$timezone');

      // Fetch city, state, and country using reverse geocoding
      final locationDetails = await geocodingService.getLocationDetails(
          position.latitude, position.longitude);
      final cityName = locationDetails['city'] ??
          locationDetails['state'] ??
          locationDetails['country'] ??
          null;
      final stateName = locationDetails['state'];
      final countryName = locationDetails['country'];

      // Fetch current weather and forecast
      final current = await repo.getCurrentWeather(
          position.latitude, position.longitude, timezone);
      print('Current weather: ' + current.toString());
      final forecast = await repo.getForecast(
          position.latitude, position.longitude, timezone);
      print('Forecast: ' + forecast.toString());

      // Fetch detailed weather (7-day forecast)
      final detailedWeather = await repo.getDetailedWeather(
          position.latitude, position.longitude, timezone);
      print('Detailed weather: ' + detailedWeather.toString());

      state = state.copyWith(
        currentWeather: current,
        forecast: forecast,
        detailedWeather: detailedWeather,
        isLoading: false,
        cityName: cityName,
        stateName: stateName,
        countryName: countryName,
      );
    } catch (e, st) {
      print('Weather fetch error: ' + e.toString());
      print(st);
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref);
});
