import 'package:flutter/material.dart';

class CurrentWeather {
  final String city; // empty for forecast items
  final String date;
  final String temp;
  final String wind;
  final String humidity;
  final String condition;
   final String iconUrl; // instead of IconData

  CurrentWeather({
    required this.city,
    required this.date,
    required this.temp,
    required this.wind,
    required this.humidity,
    required this.condition,
    required this.iconUrl,
  });

  /// Shared method for icon mapping
  // static IconData _mapConditionToIcon(String text) {
  //   final condition = text.toLowerCase();
  //   if (condition.contains('sunny')) return Icons.wb_sunny;
  //   if (condition.contains('rain')) return Icons.grain;
  //   if (condition.contains('storm')) return Icons.thunderstorm;
  //   if (condition.contains('snow')) return Icons.ac_unit;
  //   return Icons.cloud;
  // }

  /// Parse from "current weather" API JSON
  factory CurrentWeather.fromApiCurrent(Map<String, dynamic> json) {
    final current = json['current'];
    final location = json['location'];

    return CurrentWeather(
      city: location['name'] ?? '',
      date: location['localtime']?.split(' ')[0] ?? '',
      temp: "${current['temp_c']}°C",
      wind: "${current['wind_kph']} km/h",
      humidity: "${current['humidity']}%",
      condition: current['condition']['text'] ?? '',
      iconUrl: "https:${current['condition']['icon']}",
    );
  }

  /// Parse from a forecast-day JSON item
  factory CurrentWeather.fromApiForecast(Map<String, dynamic> json) {
    final day = json['day'];

    return CurrentWeather(
      city: '', // forecast entries don't have city
      date: json['date'] ?? '',
      temp: "${day['avgtemp_c']}°C",
      wind: "${day['maxwind_kph']} km/h",
      humidity: "${day['avghumidity']}%",
      condition: day['condition']['text'] ?? '',
      iconUrl: "https:${day['condition']['icon']}",
    );
  }
}
