import 'package:flutter/material.dart';
import '../widgets/search_box.dart';
import '../widgets/current_weather_card.dart';
import '../widgets/forecast_list.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bgLight = const Color(0xFFDCE9F4);

    final dummyForecast = [
      {"date": "2023-06-20", "temp": "17.64°C", "wind": "0.73 M/S", "humidity": "70%", "icon": Icons.cloud},
      {"date": "2023-06-21", "temp": "16.78°C", "wind": "2.72 M/S", "humidity": "83%", "icon": Icons.wb_sunny},
      {"date": "2023-06-22", "temp": "18.20°C", "wind": "1.49 M/S", "humidity": "72%", "icon": Icons.thunderstorm},
      {"date": "2023-06-23", "temp": "17.08°C", "wind": "0.9 M/S", "humidity": "89%", "icon": Icons.water},
    ];

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

            // Main content responsive
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isWideScreen = constraints.maxWidth > 800;

                  if (isWideScreen) {
                    // Desktop / tablet: Row layout
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left column (SearchBox)
                        Expanded(
                          flex: 3,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SearchBox(
                              controller: searchController,
                              onSearch: () {},
                              onUseLocation: () {},
                            ),
                          ),
                        ),

                        // Right column (CurrentWeatherCard + Forecast)
                        Expanded(
                          flex: 7,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CurrentWeatherCard(
                                  city: "London",
                                  date: "2023-06-19",
                                  temp: "18.71°C",
                                  wind: "4.31 M/S",
                                  humidity: "76%",
                                  condition: "Moderate rain",
                                  icon: Icons.cloud,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "4-Day Forecast",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),
                                ForecastList(forecast: dummyForecast),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile: Column layout
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SearchBox(
                            controller: searchController,
                            onSearch: () {},
                            onUseLocation: () {},
                          ),
                          const SizedBox(height: 20),
                          const CurrentWeatherCard(
                            city: "London",
                            date: "2023-06-19",
                            temp: "18.71°C",
                            wind: "4.31 M/S",
                            humidity: "76%",
                            condition: "Moderate rain",
                            icon: Icons.cloud,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "4-Day Forecast",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ForecastList(forecast: dummyForecast),
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
