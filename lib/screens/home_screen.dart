import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/widgets/forecast_card.dart';
import '../widgets/search_box.dart';
import '../widgets/current_weather_card.dart';
import '../providers/weather_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isSubscribed = false;
  String? subscribedEmail;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherAndForecast("New York");
    });
  }

  Future<void> _handleSearch() async {
    final q = searchController.text.trim();
    if (q.isEmpty) return;
    await context.read<WeatherProvider>().fetchWeatherAndForecast(q);
  }

  Future<void> _handleUseLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      await context.read<WeatherProvider>().fetchWeatherAndForecastByCoords(
            pos.latitude,
            pos.longitude,
          );
    } catch (e) {
      context.read<WeatherProvider>().notifyListeners();
    }
  }

  /// Email subscription dialog
  void _showSubscribeDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Subscribe to Daily Forecast"),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Enter your email",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (_isValidEmail(email)) {
                _subscribe(email);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid email")),
                );
              }
            },
            child: const Text("Subscribe"),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) =>
      email.isNotEmpty && email.contains('@');

  void _subscribe(String email) {
    setState(() {
      isSubscribed = true;
      subscribedEmail = email;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Subscribed with $email")),
    );
    print("Subscribed: $email");
  }

  void _unsubscribe() {
    setState(() {
      isSubscribed = false;
      subscribedEmail = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Unsubscribed successfully")),
    );
    print("Unsubscribed");
  }

  @override
  Widget build(BuildContext context) {
    final bgLight = const Color(0xFFDCE9F4);
    final weatherProvider = context.watch<WeatherProvider>();

    final hasData = weatherProvider.currentWeather != null &&
        weatherProvider.visibleForecast.isNotEmpty;

    final currentCard = hasData
        ? CurrentWeatherCard(
            city: weatherProvider.currentWeather!.city,
            date: weatherProvider.currentWeather!.date,
            temp: weatherProvider.currentWeather!.temp,
            wind: weatherProvider.currentWeather!.wind,
            humidity: weatherProvider.currentWeather!.humidity,
            condition: weatherProvider.currentWeather!.condition,
            iconUrl: weatherProvider.currentWeather!.iconUrl,
          )
        : null;

    Widget buildRightPanel() {
      if (weatherProvider.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!hasData) {
        return const Center(child: Text("No weather data"));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          currentCard!,
          const SizedBox(height: 20),
          const Text(
            "Forecast",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weatherProvider.visibleForecast.map((f) {
              return ForecastCard(
                date: f.date,
                temp: f.temp,
                wind: f.wind,
                humidity: f.humidity,
                iconUrl: f.iconUrl,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          if (weatherProvider.hasMore)
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: weatherProvider.isLoadingMore
                    ? null
                    : () async {
                        await context
                            .read<WeatherProvider>()
                            .loadMoreForecast(step: 4);
                      },
                child: weatherProvider.isLoadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Load more"),
              ),
            ),
        ],
      );
    }

    final searchPanel = SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SearchBox(
            controller: searchController,
            onSearch: _handleSearch,
            onUseLocation: _handleUseLocation,
            errorText: weatherProvider.errorMessage,
            isLoading: weatherProvider.isLoading,
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<String>>(
            future: context.read<WeatherProvider>().getTodayHistoryKeys(),
            builder: (context, snap) {
              final keys = snap.data ?? [];
              if (keys.isEmpty) return const SizedBox.shrink();
              return Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: keys.map((k) {
                    final label = k.startsWith('city:')
                        ? k.substring(5)
                        : 'My Location';
                    return ActionChip(
                      label: Text(label),
                      onPressed: () async {
                        await context
                            .read<WeatherProvider>()
                            .loadFromCacheByKey(k);
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF5A7BD0),
              child: const Center(
                child: Text(
                  "Weather Dashboard",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: searchPanel),
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: buildRightPanel(),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          searchPanel,
                          const SizedBox(height: 16),
                          buildRightPanel(),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isSubscribed) {
            _unsubscribe();
          } else {
            _showSubscribeDialog();
          }
        },
        label: Text(isSubscribed ? "Unsubscribe" : "Subscribe"),
        icon: Icon(isSubscribed ? Icons.cancel : Icons.email),
        backgroundColor: isSubscribed ? Colors.red : Colors.blue,
      ),
    );
  }
}
