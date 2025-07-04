import '../data/news_api_service.dart';

abstract class NewsRepository {
  Future<Map<String, dynamic>> getTopHeadlines({String? category});
  Future<Map<String, dynamic>> searchNews(String query);
}

class NewsRepositoryImpl implements NewsRepository {
  final NewsApiService apiService;
  final String apiKey;
  NewsRepositoryImpl(this.apiService, this.apiKey);

  @override
  Future<Map<String, dynamic>> getTopHeadlines({String? category}) async {
    final response =
        await apiService.getTopHeadlines(apiKey, category: category);
    return response.data;
  }

  @override
  Future<Map<String, dynamic>> searchNews(String query) async {
    final response = await apiService.searchNews(apiKey, query);
    return response.data;
  }
}
