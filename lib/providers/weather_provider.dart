// providers/weather_provider.dart
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
      _forecast = forecastDays.map((day) => ForecastDay.fromApi(day)).toList();
    } catch (e) {
      _currentWeather = null;
      _forecast = [];
      _errorMessage = _friendlyError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // NEW: coordinates version for "Use Current Location"
  Future<void> fetchWeatherAndForecastByCoords(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weatherJson = await _weatherService.getWeatherByCoords(lat, lon);
      final forecastJson = await _weatherService.getForecastByCoords(lat, lon, days: 4);

      _currentWeather = CurrentWeather.fromApi(weatherJson);
      final forecastDays = forecastJson['forecast']['forecastday'] as List;
      _forecast = forecastDays.map((day) => ForecastDay.fromApi(day)).toList();
    } catch (e) {
      _currentWeather = null;
      _forecast = [];
      _errorMessage = _friendlyError(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.toLowerCase().contains('no matching location')) {
      return 'No matching location found. Please try another city.';
    }
    if (msg.toLowerCase().contains('permission')) {
      return 'Location permission denied. Please enable it in settings or search by city.';
    }
    return 'Something went wrong. Please try again.';
  }
}
