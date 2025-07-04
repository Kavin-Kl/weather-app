import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/news_api_service.dart';
import '../domain/news_repository.dart';
import '../../../core/providers.dart';

const String newsApiKey = 'bcdcdec9526646248c2e7aac21a82557';

final newsApiServiceProvider = Provider<NewsApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return NewsApiService(dio);
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final apiService = ref.watch(newsApiServiceProvider);
  return NewsRepositoryImpl(apiService, newsApiKey);
});
