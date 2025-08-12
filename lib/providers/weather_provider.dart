import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  Map<String, dynamic>? _weatherData;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get weatherData => _weatherData;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeather(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _weatherService.getWeatherByCity(city);
      _weatherData = data;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
