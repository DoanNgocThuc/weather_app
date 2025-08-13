import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/CurrentWeather.dart';
import '../models/ForecastDay.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  bool _isLoading = false;
  CurrentWeather? _currentWeather;
  List<ForecastDay> _forecast = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  CurrentWeather? get currentWeather => _currentWeather;
  List<ForecastDay> get forecast => _forecast;
  String? get errorMessage => _errorMessage;

  Future<void> fetchWeatherAndForecast(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weatherJson = await _weatherService.getWeatherByCity(city);
      final forecastJson = await _weatherService.getForecast(city, days: 4);

      _currentWeather = CurrentWeather.fromApi(weatherJson);

      final forecastDays = forecastJson['forecast']['forecastday'] as List;
      _forecast = forecastDays
          .map((day) => ForecastDay.fromApi(day))
          .toList();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
