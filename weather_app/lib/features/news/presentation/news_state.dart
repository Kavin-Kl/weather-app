import 'package:equatable/equatable.dart';

class NewsState extends Equatable {
  final List<dynamic>? articles;
  final bool isLoading;
  final String? error;

  const NewsState({
    this.articles,
    this.isLoading = false,
    this.error,
  });

  NewsState copyWith({
    List<dynamic>? articles,
    bool? isLoading,
    String? error,
  }) {
    return NewsState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [articles, isLoading, error];
}
