import 'package:flutter/material.dart';

class CurrentWeatherCard extends StatelessWidget {
  final String city;
  final String date;
  final String temp;
  final String wind;
  final String humidity;
  final String condition;
  final String iconUrl;

  const CurrentWeatherCard({
    super.key,
    required this.city,
    required this.date,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.condition,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    final themeBlue = const Color(0xFF5A7BD0);

    return Container(
      decoration: BoxDecoration(
        color: themeBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$city ($date)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text("Temperature: $temp", style: const TextStyle(color: Colors.white)),
                Text("Wind: $wind", style: const TextStyle(color: Colors.white)),
                Text("Humidity: $humidity", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          Column(
            children: [
              Image.network(iconUrl, width: 50, height: 50),
              const SizedBox(height: 4),
              Text(condition, style: const TextStyle(color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }
}
