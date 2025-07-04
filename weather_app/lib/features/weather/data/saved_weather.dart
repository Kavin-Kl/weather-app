import 'package:hive/hive.dart';

part 'saved_weather.g.dart';

@HiveType(typeId: 1)
class SavedWeather extends HiveObject {
  @HiveField(0)
  final DateTime date;
  @HiveField(1)
  final double temp;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String icon;

  SavedWeather({
    required this.date,
    required this.temp,
    required this.description,
    required this.icon,
  });
}
