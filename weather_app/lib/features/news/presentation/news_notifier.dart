import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'news_state.dart';
import 'news_providers.dart';

class NewsNotifier extends StateNotifier<NewsState> {
  NewsNotifier(this.ref) : super(const NewsState());
  final Ref ref;

  Future<void> fetchTopHeadlines({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(newsRepositoryProvider);
      final data = await repo.getTopHeadlines(category: category);
      state = state.copyWith(
        articles: data['articles'] as List<dynamic>?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchNews(String query) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(newsRepositoryProvider);
      final data = await repo.searchNews(query);
      state = state.copyWith(
        articles: data['articles'] as List<dynamic>?,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final newsNotifierProvider =
    StateNotifierProvider<NewsNotifier, NewsState>((ref) {
  return NewsNotifier(ref);
});
