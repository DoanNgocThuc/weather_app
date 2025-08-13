import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeatherAndForecast("New York");
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgLight = const Color(0xFFDCE9F4);
    final weatherProvider = Provider.of<WeatherProvider>(context);

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
              child: weatherProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : weatherProvider.errorMessage != null
                      ? Center(
                          child: Text(
                            "Error: ${weatherProvider.errorMessage}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            bool isWideScreen = constraints.maxWidth > 800;

                            if (weatherProvider.currentWeather == null ||
                                weatherProvider.forecast.isEmpty) {
                              return const Center(
                                  child: Text("No weather data"));
                            }

                            final currentCard = CurrentWeatherCard(
                              city: weatherProvider.currentWeather!.city,
                              date: weatherProvider.currentWeather!.date,
                              temp: weatherProvider.currentWeather!.temp,
                              wind: weatherProvider.currentWeather!.wind,
                              humidity:
                                  weatherProvider.currentWeather!.humidity,
                              condition:
                                  weatherProvider.currentWeather!.condition,
                              icon: weatherProvider.currentWeather!.icon,
                            );

                            if (isWideScreen) {
                              return Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: SearchBox(
                                        controller: searchController,
                                        onSearch: () {
                                          weatherProvider
                                              .fetchWeatherAndForecast(
                                                  searchController.text);
                                        },
                                        onUseLocation: () {},
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 7,
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          currentCard,
                                          const SizedBox(height: 20),
                                          const Text(
                                            "4-Day Forecast",
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                    FontWeight.bold),
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
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    SearchBox(
                                      controller: searchController,
                                      onSearch: () {
                                        weatherProvider
                                            .fetchWeatherAndForecast(
                                                searchController.text);
                                      },
                                      onUseLocation: () {},
                                    ),
                                    const SizedBox(height: 20),
                                    currentCard,
                                    const SizedBox(height: 20),
                                    const Text(
                                      "4-Day Forecast",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
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
