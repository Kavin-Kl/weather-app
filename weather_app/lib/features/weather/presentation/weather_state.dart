import 'package:equatable/equatable.dart';

class WeatherState extends Equatable {
  final Map<String, dynamic>? currentWeather;
  final Map<String, dynamic>? forecast;
  final Map<String, dynamic>? detailedWeather; // Data from One Call API
  final Map<String, dynamic>? airPollution; // Data from Air Pollution API
  final bool isLoading;
  final String? error;

  const WeatherState({
    this.currentWeather,
    this.forecast,
    this.detailedWeather,
    this.airPollution,
    this.isLoading = false,
    this.error,
  });

  WeatherState copyWith({
    Map<String, dynamic>? currentWeather,
    Map<String, dynamic>? forecast,
    Map<String, dynamic>? detailedWeather,
    Map<String, dynamic>? airPollution,
    bool? isLoading,
    String? error,
  }) {
    return WeatherState(
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      detailedWeather: detailedWeather ?? this.detailedWeather,
      airPollution: airPollution ?? this.airPollution,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        currentWeather,
        forecast,
        detailedWeather,
        airPollution,
        isLoading,
        error
      ];
}
