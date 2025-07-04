import 'package:hive/hive.dart';

part 'saved_news.g.dart';

@HiveType(typeId: 0)
class SavedNews extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String url;
  @HiveField(2)
  final String? imageUrl;
  @HiveField(3)
  final String? source;
  @HiveField(4)
  final String? description;

  SavedNews({
    required this.title,
    required this.url,
    this.imageUrl,
    this.source,
    this.description,
  });
}
