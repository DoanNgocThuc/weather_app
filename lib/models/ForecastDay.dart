import 'package:flutter/material.dart';

class ForecastDay {
  final String date;
  final String temp;
  final String wind;
  final String humidity;
  final IconData icon;

  ForecastDay({
    required this.date,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.icon,
  });

  factory ForecastDay.fromApi(Map<String, dynamic> json) {
    final day = json['day'];

    IconData iconData = Icons.cloud;
    final conditionText = (day['condition']['text'] ?? "").toLowerCase();
    if (conditionText.contains('sunny')) iconData = Icons.wb_sunny;
    else if (conditionText.contains('rain')) iconData = Icons.grain;
    else if (conditionText.contains('storm')) iconData = Icons.thunderstorm;
    else if (conditionText.contains('snow')) iconData = Icons.ac_unit;

    return ForecastDay(
      date: json['date'] ?? '',
      temp: "${day['avgtemp_c']}°C",
      wind: "${day['maxwind_kph']} km/h",
      humidity: "${day['avghumidity']}%",
      icon: iconData,
    );
  }
}