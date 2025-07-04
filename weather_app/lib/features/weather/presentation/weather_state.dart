import 'package:equatable/equatable.dart';

class WeatherState extends Equatable {
  final Map<String, dynamic>? currentWeather;
  final Map<String, dynamic>? forecast;
  final bool isLoading;
  final String? error;

  const WeatherState({
    this.currentWeather,
    this.forecast,
    this.isLoading = false,
    this.error,
  });

  WeatherState copyWith({
    Map<String, dynamic>? currentWeather,
    Map<String, dynamic>? forecast,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [currentWeather, forecast, isLoading, error];
}
