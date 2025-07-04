import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../weather/presentation/weather_notifier.dart';
import '../news/presentation/news_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final newsState = ref.watch(newsNotifierProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather & News Dashboard'),
        elevation: 0,
        backgroundColor: Colors.blueAccent,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Example: fetch weather for a default location and news
          await ref
              .read(weatherNotifierProvider.notifier)
              .fetchWeather(37.7749, -122.4194); // San Francisco
          await ref.read(newsNotifierProvider.notifier).fetchTopHeadlines();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Weather Section
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: weatherState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : weatherState.error != null
                        ? Text('Error: ${weatherState.error}')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Weather',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (weatherState.currentWeather != null) ...[
                                Text(
                                  '${weatherState.currentWeather!['name'] ?? ''}',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '${weatherState.currentWeather!['main']?['temp']?.toStringAsFixed(1) ?? '--'}°C',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  weatherState.currentWeather!['weather']?[0]
                                          ?['description'] ??
                                      '',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ]
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            // News Section
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: newsState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : newsState.error != null
                        ? Text('Error: ${newsState.error}')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Top Headlines',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              if (newsState.articles != null)
                                ...newsState.articles!
                                    .take(3)
                                    .map((article) => ListTile(
                                          title: Text(article['title'] ?? ''),
                                          subtitle: Text(
                                              article['source']?['name'] ?? ''),
                                        ))
                            ],
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
