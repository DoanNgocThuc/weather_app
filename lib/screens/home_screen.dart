// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../widgets/search_box.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';
import '../providers/weather_provider.dart';

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
    // Load New York on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherAndForecast("New York");
    });
  }

  Future<void> _handleSearch() async {
    final q = searchController.text.trim();
    if (q.isEmpty) {
      context.read<WeatherProvider>().fetchWeatherAndForecast("New York"); // or ignore
      return;
    }
    await context.read<WeatherProvider>().fetchWeatherAndForecast(q);
  }

  Future<void> _handleUseLocation() async {
    try {
      final svcEnabled = await Geolocator.isLocationServiceEnabled();
      if (!svcEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      await context
          .read<WeatherProvider>()
          .fetchWeatherAndForecastByCoords(pos.latitude, pos.longitude);
    } catch (e) {
      // Let provider show a friendly message
      context.read<WeatherProvider>().fetchWeatherAndForecast("New York");
      final prov = context.read<WeatherProvider>();
      prov
        // .._errorMessage = 'Could not use your location. You can search by city instead.'
        ..notifyListeners();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgLight = const Color(0xFFDCE9F4);
    final weatherProvider = context.watch<WeatherProvider>();

    final hasData = weatherProvider.currentWeather != null && weatherProvider.forecast.isNotEmpty;

    final currentCard = hasData
        ? CurrentWeatherCard(
            city: weatherProvider.currentWeather!.city,
            date: weatherProvider.currentWeather!.date,
            temp: weatherProvider.currentWeather!.temp,
            wind: weatherProvider.currentWeather!.wind,
            humidity: weatherProvider.currentWeather!.humidity,
            condition: weatherProvider.currentWeather!.condition,
            icon: weatherProvider.currentWeather!.icon,
          )
        : null;

    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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

            // Main content
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;

                  final searchPanel = SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SearchBox(
                      controller: searchController,
                      onSearch: _handleSearch,
                      onUseLocation: _handleUseLocation,
                      errorText: weatherProvider.errorMessage, // 👈 show errors here
                      isLoading: weatherProvider.isLoading,
                    ),
                  );

                  final rightPanel = SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: weatherProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : !hasData
                            ? const Center(child: Text("No weather data"))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  currentCard!,
                                  const SizedBox(height: 20),
                                  const Text(
                                    "4-Day Forecast",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  ForecastList(
                                    forecast: weatherProvider.forecast
                                        .map((f) => {
                                              "date": f.date,
                                              "temp": f.temp,
                                              "wind": f.wind,
                                              "humidity": f.humidity,
                                              "icon": f.icon,
                                            })
                                        .toList(),
                                  ),
                                ],
                              ),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: searchPanel),
                        Expanded(flex: 7, child: rightPanel),
                      ],
                    );
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          searchPanel,
                          rightPanel,
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
    );
  }
}
