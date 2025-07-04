import 'package:dio/dio.dart';

class NewsApiService {
  final Dio dio;
  NewsApiService(this.dio);

  Future<Response> getTopHeadlines(String apiKey, {String? category}) {
    return dio.get(
      'https://newsapi.org/v2/top-headlines',
      queryParameters: {
        'country': 'us',
        'apiKey': apiKey,
        if (category != null) 'category': category,
      },
    );
  }

  Future<Response> searchNews(String apiKey, String query) {
    return dio.get(
      'https://newsapi.org/v2/everything',
      queryParameters: {
        'q': query,
        'apiKey': apiKey,
      },
    );
  }
}
