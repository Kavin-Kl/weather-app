import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'weather_state.dart';
import 'weather_providers.dart';

class WeatherNotifier extends StateNotifier<WeatherState> {
  WeatherNotifier(this.ref) : super(const WeatherState());
  final Ref ref;

  Future<void> fetchWeather(double lat, double lon) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(weatherRepositoryProvider);
      final current = await repo.getCurrentWeather(lat, lon);
      final forecast = await repo.getForecast(lat, lon);
      state = state.copyWith(
        currentWeather: current,
        forecast: forecast,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(ref);
});
