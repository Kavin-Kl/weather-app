import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_state.dart';
import 'weather_providers.dart';
import '../../../core/location_service.dart';

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this.ref) : super(const WeatherState());
  final Ref ref;

  Future<void> fetchWeatherForCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      final repo = ref.read(weatherRepositoryProvider);

      print(
          'Fetching weather for: lat=${position.latitude}, lon=${position.longitude}');

      // Fetch current weather and forecast (can potentially remove if One Call is sufficient)
      final current =
          await repo.getCurrentWeather(position.latitude, position.longitude);
      print('Current weather: ' + current.toString());
      final forecast =
          await repo.getForecast(position.latitude, position.longitude);
      print('Forecast: ' + forecast.toString());

      // Fetch detailed weather and air pollution using One Call API
      final detailedWeather =
          await repo.getDetailedWeather(position.latitude, position.longitude);
      print('Detailed weather: ' + detailedWeather.toString());
      final airPollution =
          await repo.getAirPollution(position.latitude, position.longitude);
      print('Air pollution: ' + airPollution.toString());

      state = state.copyWith(
        currentWeather: current,
        forecast:
            forecast, // Keep if needed for hourly/daily breakdown not in One Call
        detailedWeather: detailedWeather,
        airPollution: airPollution,
        isLoading: false,
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
