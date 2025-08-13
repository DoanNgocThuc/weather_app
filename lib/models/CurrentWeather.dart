import 'package:flutter/material.dart';

class CurrentWeather {
  final String city;
  final String date;
  final String temp;
  final String wind;
  final String humidity;
  final String condition;
  final IconData icon; // we still store an Icon for simplicity

  CurrentWeather({
    required this.city,
    required this.date,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.condition,
    required this.icon,
  });

  factory CurrentWeather.fromApi(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    // Map condition text to icon
    IconData iconData = Icons.cloud;
    final conditionText = (current['condition']['text'] ?? "").toLowerCase();
    if (conditionText.contains('sunny')) iconData = Icons.wb_sunny;
    else if (conditionText.contains('rain')) iconData = Icons.grain;
    else if (conditionText.contains('storm')) iconData = Icons.thunderstorm;
    else if (conditionText.contains('snow')) iconData = Icons.ac_unit;

    return CurrentWeather(
      city: location['name'] ?? '',
      date: location['localtime']?.split(' ')[0] ?? '',
      temp: "${current['temp_c']}°C",
      wind: "${current['wind_kph']} km/h",
      humidity: "${current['humidity']}%",
      condition: current['condition']['text'] ?? '',
      icon: iconData,
    );
  }
}