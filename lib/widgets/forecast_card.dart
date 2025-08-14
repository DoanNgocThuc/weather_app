import 'package:flutter/material.dart';

class ForecastCard extends StatelessWidget {
  final String date;
  final String temp;
  final String wind;
  final String humidity;
  final String iconUrl;

  const ForecastCard({
    super.key,
    required this.date,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[700],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "($date)",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Image.network(iconUrl, width: 50, height: 50),
          const SizedBox(height: 8),
          Text("Temp: $temp", style: const TextStyle(color: Colors.white)),
          Text("Wind: $wind", style: const TextStyle(color: Colors.white)),
          Text("Humidity: $humidity", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
