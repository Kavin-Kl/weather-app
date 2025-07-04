import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; // Required for ImageFilter
import 'package:hive_flutter/hive_flutter.dart';

// Ensure these paths are correct relative to your project structure
import '../weather/presentation/weather_notifier.dart';
import '../news/presentation/news_notifier.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedTab = 0;
  String _searchQuery = '';

  // Controller for the Scaffold to open/close the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _selectedCategory; // Add this to track selected category
  List<dynamic>? _categoryArticles; // Store filtered articles for category

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(weatherNotifierProvider.notifier)
          .fetchWeatherForCurrentLocation();
      ref.read(newsNotifierProvider.notifier).fetchTopHeadlines();
    });
  }

  Future<void> _refresh() async {
    // Only refresh the current tab's data
    if (_selectedTab == 0) {
      await ref
          .read(weatherNotifierProvider.notifier)
          .fetchWeatherForCurrentLocation();
    } else if (_selectedTab == 1) {
      // Discover/News tab
      await ref.read(newsNotifierProvider.notifier).fetchTopHeadlines();
    } else if (_selectedTab == 3 && _searchQuery.isNotEmpty) {
      // Search tab if a query exists
      // Assuming you have a search news method in news_notifier
      // await ref.read(newsNotifierProvider.notifier).searchNews(_searchQuery);
      await ref
          .read(newsNotifierProvider.notifier)
          .fetchTopHeadlines(); // Fallback
    }
    // Categories and Saved tabs might have their own refresh logic or none
  }

  // Helper method to set the selected tab and clear search query if not on search tab
  void _onTabSelected(int index) {
    setState(() {
      _selectedTab = index;
      if (index != 3) {
        _searchQuery = ''; // Clear search when switching off search tab
      }
      // Close the drawer after selecting a tab
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final newsState = ref.watch(newsNotifierProvider);

    Widget bodyWidget;
    if (_selectedTab == 0) {
      bodyWidget = _WeatherSection(weatherState: weatherState);
    } else if (_selectedTab == 2) {
      // Categories tab
      bodyWidget = _CategoriesSection(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) async {
          setState(() {
            _selectedCategory = category;
          });
          if (category == 'Weather') {
            setState(() {
              _selectedTab = 0;
            });
          } else if (category == 'News') {
            setState(() {
              _selectedTab = 1;
            });
          } else if (category == 'Sports' || category == 'Science') {
            // Fetch news for the selected category
            await ref
                .read(newsNotifierProvider.notifier)
                .fetchTopHeadlines(category: category.toLowerCase());
            setState(() {
              _categoryArticles = ref.read(newsNotifierProvider).articles;
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected category: $category')),
            );
          }
        },
        // Pass articles only for sports/science, else null
        categoryArticles:
            (_selectedCategory == 'Sports' || _selectedCategory == 'Science')
                ? _categoryArticles
                : null,
      );
    } else if (_selectedTab == 3) {
      // Search tab
      bodyWidget = _NewsSearchSection(
        newsState: newsState,
        searchQuery: _searchQuery,
        onQueryChanged: (q) => setState(() => _searchQuery = q),
      );
    } else if (_selectedTab == 4) {
      // Saved tab
      bodyWidget = SavedNewsSection();
    } else {
      // Default to News (Discover) section for other tabs for now,
      // you would create specific widgets for Categories and Saved if needed.
      bodyWidget = _NewsSection(newsState: newsState);
    }

    // Get current city and date for AppBar
    final currentCity = weatherState.currentWeather?['name'] ?? 'City';
    final currentDate = DateFormat('MMM dd').format(DateTime.now());

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to the Scaffold
      backgroundColor:
          Colors.transparent, // Transparent to show the gradient body
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Make AppBar transparent
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // Hamburger icon
          onPressed: () =>
              _scaffoldKey.currentState?.openDrawer(), // Open drawer
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentCity,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24, // Slightly smaller than before for AppBar
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'Today, $currentDate',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
        actions: [
          // Dynamic location tag using city and country from weatherState
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 18),
                const SizedBox(width: 4),
                Text(
                  // Show city and country if available, fallback to 'Unknown'
                  (weatherState.currentWeather?['name'] ?? 'Unknown') +
                      (weatherState.currentWeather?['sys'] != null &&
                              weatherState.currentWeather?['sys']['country'] !=
                                  null
                          ? ', ${weatherState.currentWeather?['sys']['country']}'
                          : ''),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
      extendBodyBehindAppBar: true, // Extend body behind transparent AppBar
      body: Container(
        // The cool dark black gradient background
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A), // Very dark grey/near black
              Color(0xFF000000), // Pure black
            ],
          ),
        ),
        child: SafeArea(
          // Ensures content respects notch/status bar (AppBar takes care of top padding)
          child: RefreshIndicator(
            onRefresh: _refresh,
            color: Colors.purpleAccent, // Color of the refresh indicator
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: bodyWidget,
            ),
          ),
        ),
      ),
      drawer: ClipRRect(
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Drawer(
            backgroundColor:
                Colors.white.withOpacity(0.08), // Frosted glass effect
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Make drawer header transparent
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.purpleAccent.withOpacity(0.2),
                        child: const Icon(Icons.person,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome User!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'user@example.com',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(
                  icon: Icons.cloud,
                  text: 'Weather',
                  index: 0,
                  isSelected: _selectedTab == 0,
                  onTap: () => _onTabSelected(0),
                ),
                _buildDrawerItem(
                  icon: Icons.article,
                  text: 'Discover',
                  index: 1,
                  isSelected: _selectedTab == 1,
                  onTap: () => _onTabSelected(1),
                ),
                _buildDrawerItem(
                  icon: Icons.category,
                  text: 'Categories',
                  index: 2,
                  isSelected: _selectedTab == 2,
                  onTap: () => _onTabSelected(2),
                ),
                _buildDrawerItem(
                  icon: Icons.search,
                  text: 'Search',
                  index: 3,
                  isSelected: _selectedTab == 3,
                  onTap: () => _onTabSelected(3),
                ),
                _buildDrawerItem(
                  icon: Icons.bookmark,
                  text: 'Saved',
                  index: 4,
                  isSelected: _selectedTab == 4,
                  onTap: () => _onTabSelected(4),
                ),
                const Divider(color: Colors.white12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build DrawerListTile for consistency and selection styling
  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    int? index, // Optional index to check for selection
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.purpleAccent.withOpacity(0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? Colors.purpleAccent : Colors.white70),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.purpleAccent : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

// --- Weather Section Widget ---
// This widget displays the weather details, replacing the need for an AppBar title.
class _WeatherSection extends StatelessWidget {
  final dynamic weatherState;
  const _WeatherSection({required this.weatherState});

  @override
  Widget build(BuildContext context) {
    final current = weatherState.detailedWeather?['current'];
    final hourly = weatherState.detailedWeather?['hourly'] as List<dynamic>?;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Top section with City and Date is now in AppBar
        const SizedBox(height: 16), // Add some space below AppBar
        // Main Temperature Display
        Center(
          child: Column(
            children: [
              Text(
                '${current != null && current['temp'] != null ? current['temp'].toStringAsFixed(0) : '--'}°C',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 100,
                    fontWeight: FontWeight.w300),
              ),
              Text(
                current?['weather'] != null &&
                        current['weather'] is List &&
                        current['weather'].isNotEmpty
                    ? current['weather'][0]['description']
                            ?.toString()
                            .toUpperCase() ??
                        ''
                    : 'MOSTLY CLOUDY',
                style: const TextStyle(color: Colors.white70, fontSize: 20),
              ),
              const SizedBox(height: 16),
              // Min/Max Temperature
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.arrow_downward,
                      color: Colors.white70, size: 18),
                  Text(
                    ' ${current != null && current['temp_min'] != null ? current['temp_min'].toStringAsFixed(0) : '--'}°',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.arrow_upward,
                      color: Colors.white70, size: 18),
                  Text(
                    ' ${current != null && current['temp_max'] != null ? current['temp_max'].toStringAsFixed(0) : '--'}°',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Additional weather details section (Wind, UV Index, Humidity)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.08), // Translucent background for the card
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Row(
            // Using const for efficiency since children are const
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _WeatherDetailItem(
                  Icons.waves, '12 km/h', 'Wind'), // Example values
              _WeatherDetailItem(Icons.wb_sunny_outlined, 'UV12', 'UV Index'),
              _WeatherDetailItem(Icons.water_drop, '80%', 'Humidity'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Hourly Forecast title
        const Text(
          'Hourly Forecast',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Hourly Forecast List
        if (hourly != null && hourly.isNotEmpty)
          SizedBox(
            height: 120, // Height for the horizontal list of hourly cards
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  hourly.length < 8 ? hourly.length : 8, // Display next 8 hours
              itemBuilder: (context, index) {
                final h = hourly[index];
                final dt =
                    DateTime.fromMillisecondsSinceEpoch((h['dt'] ?? 0) * 1000);
                final hour = DateFormat('ha').format(dt);
                final temp =
                    h['temp'] != null ? h['temp'].toStringAsFixed(0) : '--';
                return Container(
                  width: 80, // Width of each hourly card
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color:
                        Colors.white.withOpacity(0.1), // Translucent background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)), // Subtle border
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(hour,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15)),
                      const SizedBox(height: 8),
                      _getWeatherIcon(
                          h['weather'] != null && h['weather'].isNotEmpty
                              ? h['weather'][0]['icon']
                              : null),
                      const SizedBox(height: 8),
                      Text('$temp°',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // Helper widget for individual weather detail items
  // Made into a separate StatelessWidget for better readability and reusability
  // and marked as `const` for compile-time optimization.
}

// Separate stateless widget for weather detail items for reusability
class _WeatherDetailItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherDetailItem(
      this.icon, this.value, this.label); // Added const constructor

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

// Helper function to map OpenWeatherMap icon codes to Flutter Icons
// Placed outside the build method or as a static method/top-level function
// for better organization.
Widget _getWeatherIcon(String? iconCode) {
  // You'd ideally map OpenWeatherMap icon codes to Flutter Icons
  // For demonstration, let's use a simple mapping or default
  switch (iconCode) {
    case '01d':
    case '01n':
      return const Icon(Icons.wb_sunny, color: Colors.yellow, size: 30);
    case '02d':
    case '02n':
      return const Icon(Icons.cloud_queue, color: Colors.white70, size: 30);
    case '03d':
    case '03n':
    case '04d':
    case '04n':
      return const Icon(Icons.cloud, color: Colors.white70, size: 30);
    case '09d':
    case '09n':
      return const Icon(Icons.cloudy_snowing,
          color: Colors.blueGrey, size: 30); // Using this as a rain/drizzle
    case '10d':
    case '10n':
      return const Icon(Icons.beach_access,
          color: Colors.blueAccent, size: 30); // Rain
    case '11d':
    case '11n':
      return const Icon(Icons.thunderstorm, color: Colors.grey, size: 30);
    case '13d':
    case '13n':
      return const Icon(Icons.ac_unit,
          color: Colors.lightBlue, size: 30); // Snow
    case '50d':
    case '50n':
      return const Icon(Icons.foggy,
          color: Colors.white54, size: 30); // Mist/Fog
    default:
      return const Icon(Icons.cloud,
          color: Colors.white70, size: 30); // Default icon
  }
}

// --- News Section Widget ---
class _NewsSection extends StatelessWidget {
  final dynamic newsState;
  const _NewsSection({required this.newsState});

  @override
  Widget build(BuildContext context) {
    final articles = newsState.articles ?? [];
    final featured = articles.isNotEmpty ? articles.first : null;
    final rest = articles.length > 1 ? articles.sublist(1) : [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        const SizedBox(height: 16), // Add some space below AppBar
        if (featured != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 200, // Increased height for featured article
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(24), // More rounded corners
                  image: featured['urlToImage'] != null
                      ? DecorationImage(
                          image: NetworkImage(featured['urlToImage']),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken), // Dark overlay
                        )
                      : null,
                ),
                alignment: Alignment.bottomLeft,
                padding: const EdgeInsets.all(20), // Increased padding
                child: Text(
                  featured['title'] ?? '',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22, // Larger font for featured title
                      fontWeight: FontWeight.bold),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        const Text(
          'Latest News',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...rest.map((a) => Padding(
              padding: const EdgeInsets.only(
                  bottom: 16), // Add space between list tiles
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(
                      0.05), // Slightly lighter background for news items
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16), // Increased padding
                  title: Text(
                    a['title'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    a['source'] != null && a['source']['name'] != null
                        ? a['source']['name']
                        : '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  leading: a['urlToImage'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            a['urlToImage'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.article,
                                  color: Colors.white54),
                            ),
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(Icons.article, color: Colors.white54),
                        ),
                  trailing: IconButton(
                    icon: const Icon(Icons.bookmark_add,
                        color: Colors.purpleAccent),
                    onPressed: () async {
                      final box = await Hive.openBox('saved_news');
                      final exists = box.values.any((item) =>
                          item['title'] == a['title'] &&
                          item['url'] == a['url']);
                      if (!exists) {
                        await box.add({
                          'title': a['title'],
                          'url': a['url'],
                          'source': a['source']?['name'],
                          'urlToImage': a['urlToImage'],
                          'publishedAt': a['publishedAt'],
                          'description': a['description'],
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Article saved!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Already saved.')),
                        );
                      }
                    },
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

// --- News Search Section Widget ---
class _NewsSearchSection extends StatelessWidget {
  final dynamic newsState;
  final String searchQuery;
  final ValueChanged<String> onQueryChanged;

  const _NewsSearchSection({
    required this.newsState,
    required this.searchQuery,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final articles = newsState.articles ?? [];
    final filtered = searchQuery.isEmpty
        ? articles
        : articles
            .where((a) => (a['title'] ?? '')
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        const SizedBox(height: 16), // Add some space below AppBar
        TextField(
          style: const TextStyle(color: Colors.white),
          cursorColor: Colors.purpleAccent, // Cursor color
          decoration: InputDecoration(
            hintText: 'Search news...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.white.withOpacity(0.08),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16), // More rounded
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              // Highlight on focus
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Colors.purpleAccent, width: 1.5),
            ),
            prefixIcon: const Icon(Icons.search, color: Colors.white54),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54),
                    onPressed: () => onQueryChanged(''), // Clear search query
                  )
                : null,
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 24),
        if (filtered.isEmpty &&
            searchQuery.isNotEmpty) // "No results" if search query is active
          const Center(
            child: Text(
              'No results found for your search.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
        else if (searchQuery.isEmpty && articles.isEmpty)
          const Center(
            child: Text(
              'Start typing to search for news articles or fetch news.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
        else if (filtered.isEmpty && searchQuery.isEmpty)
          const Center(
            child: Text(
              'No articles available.', // Should only happen if initial fetch failed and no search
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          )
        else
          ...filtered.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    title: Text(
                      a['title'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      a['source'] != null && a['source']['name'] != null
                          ? a['source']['name']
                          : '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    leading: a['urlToImage'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              a['urlToImage'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.article,
                                    color: Colors.white54),
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.article,
                                color: Colors.white54),
                          ),
                  ),
                ),
              )),
      ],
    );
  }
}

// --- Categories Section Widget ---
class _CategoriesSection extends StatelessWidget {
  final String? selectedCategory;
  final void Function(String category) onCategorySelected;
  final List<dynamic>? categoryArticles;
  const _CategoriesSection(
      {this.selectedCategory,
      required this.onCategorySelected,
      this.categoryArticles});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.cloud, 'label': 'Weather'},
      {'icon': Icons.article, 'label': 'News'},
      {'icon': Icons.sports_soccer, 'label': 'Sports'},
      {'icon': Icons.science, 'label': 'Science'},
    ];
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        const SizedBox(height: 16),
        const Text(
          'Categories',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ...categories.map((cat) => Card(
              color: (selectedCategory == cat['label'])
                  ? Colors.purpleAccent.withOpacity(0.2)
                  : Colors.white.withOpacity(0.08),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Icon(cat['icon'] as IconData, color: Colors.white),
                title: Text(
                  cat['label'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                selected: selectedCategory == cat['label'],
                selectedTileColor: Colors.purpleAccent.withOpacity(0.2),
                onTap: () => onCategorySelected(cat['label'] as String),
              ),
            )),
        if (categoryArticles != null && categoryArticles!.isNotEmpty)
          ...categoryArticles!.map((a) => Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    title: Text(
                      a['title'] ?? '',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      a['source'] != null && a['source']['name'] != null
                          ? a['source']['name']
                          : '',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    leading: a['urlToImage'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              a['urlToImage'],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.article,
                                    color: Colors.white54),
                              ),
                            ),
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.article,
                                color: Colors.white54),
                          ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_add,
                          color: Colors.purpleAccent),
                      onPressed: () async {
                        // Save news article using Hive
                        final box = await Hive.openBox('saved_news');
                        // Avoid duplicates by checking title/url
                        final exists = box.values.any((item) =>
                            item['title'] == a['title'] &&
                            item['url'] == a['url']);
                        if (!exists) {
                          await box.add({
                            'title': a['title'],
                            'url': a['url'],
                            'source': a['source']?['name'],
                            'urlToImage': a['urlToImage'],
                            'publishedAt': a['publishedAt'],
                            'description': a['description'],
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Article saved!')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Already saved.')),
                          );
                        }
                      },
                    ),
                  ),
                ),
              )),
      ],
    );
  }
}

// --- Saved News Section Widget ---
class SavedNewsSection extends StatefulWidget {
  const SavedNewsSection({Key? key}) : super(key: key);
  @override
  State<SavedNewsSection> createState() => _SavedNewsSectionState();
}

class _SavedNewsSectionState extends State<SavedNewsSection> {
  late Box box;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    box = await Hive.openBox('saved_news');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('saved_news')) {
      return const Center(child: CircularProgressIndicator());
    }
    final articles = box.values.toList();
    if (articles.isEmpty) {
      return const Center(
        child: Text('No saved news articles.',
            style: TextStyle(color: Colors.white70, fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final a = articles[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              title: Text(
                a['title'] ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                a['source'] ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              leading: a['urlToImage'] != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        a['urlToImage'],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child:
                              const Icon(Icons.article, color: Colors.white54),
                        ),
                      ),
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.article, color: Colors.white54),
                    ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () async {
                  await box.deleteAt(index);
                  setState(() {});
                },
              ),
              onTap: () {
                if (a['url'] != null) {
                  // Optionally, open the article URL
                  // launch(a['url']);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
