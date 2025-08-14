import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:weather_app/widgets/forecast_card.dart';
import '../widgets/search_box.dart';
import '../widgets/current_weather_card.dart';
import '../providers/weather_provider.dart';
import 'subscribe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

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
          Text(
            "Forecast",
            style: GoogleFonts.rubik(fontSize: 18, fontWeight: FontWeight.bold),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5A7BD0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: weatherProvider.isLoadingMore
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        "Load more",
                        style: GoogleFonts.rubik(color: Colors.white),
                      ),
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
                    final label = k.startsWith('city:') ? k.substring(5) : 'My Location';
                    return ActionChip(
                      label: Text(label, style: GoogleFonts.rubik()),
                      backgroundColor: const Color(0xFF5A7BD0),
                      labelStyle: GoogleFonts.rubik(color: Colors.white),
                      onPressed: () async {
                        await context.read<WeatherProvider>().loadFromCacheByKey(k);
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
              child: Text(
                "Weather Dashboard",
                style: GoogleFonts.rubik(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscribeScreen()),
          );
        },
        label: Text("Subscribe", style: GoogleFonts.rubik(color: Colors.white)),
        icon: const Icon(Icons.email, color: Colors.white),
        backgroundColor: const Color(0xFF5A7BD0),
      ),
    );
  }
}