import 'package:flutter/material.dart';
import 'package:weather_app/widgets/forecast_card.dart';

class ForecastList extends StatelessWidget {
  final List<Map<String, dynamic>> forecast;

  const ForecastList({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: forecast.map((day) {
          return ForecastCard(
            date: day["date"],
            temp: day["temp"],
            wind: day["wind"],
            humidity: day["humidity"],
            icon: day["icon"],
          );
        }).toList(),
      ),
    );
  }
}
