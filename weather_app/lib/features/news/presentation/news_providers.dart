import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/news_api_service.dart';
import '../domain/news_repository.dart';
import '../../../core/providers.dart';

const String newsApiKey = 'YOUR_NEWSAPI_KEY'; // Replace with your API key

final newsApiServiceProvider = Provider<NewsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return NewsApiService(dio);
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final apiService = ref.watch(newsApiServiceProvider);
  return NewsRepositoryImpl(apiService, newsApiKey);
});
