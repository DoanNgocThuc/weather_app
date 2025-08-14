import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/CurrentWeather.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  bool _isLoading = false;
  bool _isLoadingMore = false;

  CurrentWeather? _currentWeather;
  List<CurrentWeather> _allForecast = [];
  int _visibleForecastCount = 4;

  String? _errorMessage;
  String _currentQueryKey = ''; // "city:New York" OR "coords:lat,lon"

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;

  CurrentWeather? get currentWeather => _currentWeather;
  List<CurrentWeather> get visibleForecast =>
      _allForecast.take(_visibleForecastCount).toList();

  bool get hasMore => _visibleForecastCount < _allForecast.length;
  String? get errorMessage => _errorMessage;

  // =========================
  // INITIAL FETCH (CITY)
  // =========================
  Future<void> fetchWeatherAndForecast(String city) async {
    _isLoading = true;
    _errorMessage = null;
    _currentQueryKey = 'city:$city';
    _visibleForecastCount = 4;
    notifyListeners();

    try {
      final weatherJson = await _weatherService.getWeatherByCity(city);
      
      final forecastJson =
          await _weatherService.getForecast(city, 14);

      _setCurrentWeather(weatherJson);
      _setAllForecastFromForecastJson(forecastJson);

      // Save to today's cache (next section uses this)
      await _saveToCache(
        key: _currentQueryKey,
        weatherJson: weatherJson,
        forecastJson: forecastJson,
      );
    } catch (e) {
      _fail(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // INITIAL FETCH (COORDS)
  // =========================
  Future<void> fetchWeatherAndForecastByCoords(double lat, double lon) async {
    _isLoading = true;
    _errorMessage = null;
    _currentQueryKey = 'coords:$lat,$lon';
    _visibleForecastCount = 4;
    notifyListeners();

    try {
      final weatherJson = await _weatherService.getWeatherByCoords(lat, lon);
      final forecastJson = await _weatherService.getForecastByCoords(
        lat,
        lon,
        14,
      );

      _setCurrentWeather(weatherJson);
      _setAllForecastFromForecastJson(forecastJson);

      await _saveToCache(
        key: _currentQueryKey,
        weatherJson: weatherJson,
        forecastJson: forecastJson,
      );
    } catch (e) {
      _fail(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  // =========================
  // LOAD MORE
  // =========================
  Future<void> loadMoreForecast({int step = 4}) async {
  if (_isLoadingMore || !hasMore) return;

  _isLoadingMore = true;
  notifyListeners();

  await Future.delayed(const Duration(milliseconds: 200)); // small UI delay

  _visibleForecastCount =
      (_visibleForecastCount + step).clamp(0, _allForecast.length);

  _isLoadingMore = false;
  notifyListeners();
}

  // =========================
  // Helpers
  // =========================
  void _setCurrentWeather(Map<String, dynamic> weatherJson) {
    _currentWeather = CurrentWeather.fromApiCurrent(weatherJson);
  }

  void _setAllForecastFromForecastJson(Map<String, dynamic> forecastJson) {
  final list = (forecastJson['forecast']['forecastday'] as List);

  // Skip today, use CurrentWeather.fromApiForecast for the rest
  _allForecast = list
      .skip(1)
      .map((d) => CurrentWeather.fromApiForecast(d as Map<String, dynamic>))
      .toList();

  _visibleForecastCount = 4;
}



  void _fail(Object e) {
    _currentWeather = null;
    _allForecast = [];
    _visibleForecastCount = 0;
    _errorMessage = _friendlyError(e);
  }

  String _friendlyError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('no matching location')) {
      return 'No matching location found. Please try another city.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ====== (used later for caching) ======
  Future<Map<String, dynamic>> _exportCurrentWeatherAsJson() async {
    // If you kept the raw JSON around, use it.
    // Otherwise reconstruct from model fields (simplified minimal JSON):
    final cw = _currentWeather!;
    return {
      "location": {"name": cw.city, "localtime": "${cw.date} 00:00"},
      "current": {
        "temp_c": double.tryParse(cw.temp.replaceAll("°C", "")) ?? 0.0,
        "wind_kph": double.tryParse(cw.wind.replaceAll(" km/h", "")) ?? 0.0,
        "humidity": int.tryParse(cw.humidity.replaceAll("%", "")) ?? 0,
        "condition": {"text": cw.condition}
      }
    };
  }

  // =========================
  // ===== NEXT SECTION ======
  // ====== CACHING (DAY) ====
  // =========================

  static const _prefsKey = 'weather_cache_v1';

  Future<void> _saveToCache({
    required String key,
    required Map<String, dynamic> weatherJson,
    required Map<String, dynamic> forecastJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final nowIso = DateTime.now().toIso8601String();

    final newEntry = {
      "key": key,
      "ts": nowIso,
      "weather": weatherJson,
      "forecast": forecastJson,
    };

    List<dynamic> list = [];
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      list = jsonDecode(raw) as List<dynamic>;
    }

    // Remove same-day duplicates for the same key
    list = list.where((e) {
      try {
        final m = e as Map<String, dynamic>;
        return !(m['key'] == key &&
            _isSameDay(DateTime.parse(m['ts']), DateTime.now()));
      } catch (_) {
        return true;
      }
    }).toList();

    list.insert(0, newEntry);
    await prefs.setString(_prefsKey, jsonEncode(list));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<List<String>> getTodayHistoryKeys() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final now = DateTime.now();
    return list
        .map((e) => e as Map<String, dynamic>)
        .where((m) => _isSameDay(DateTime.parse(m['ts']), now))
        .map((m) => m['key'] as String)
        .toList();
  }

  Future<bool> loadFromCacheByKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return false;
    final list = jsonDecode(raw) as List<dynamic>;
    final now = DateTime.now();

    for (final e in list) {
      final m = e as Map<String, dynamic>;
      if (m['key'] == key && _isSameDay(DateTime.parse(m['ts']), now)) {
        final weatherJson = Map<String, dynamic>.from(m['weather']);
        final forecastJson = Map<String, dynamic>.from(m['forecast']);

        _setCurrentWeather(weatherJson);
        _setAllForecastFromForecastJson(forecastJson);
        _visibleForecastCount = _allForecast.isEmpty
            ? 0
            : _visibleForecastCount.clamp(0, _allForecast.length);
        _errorMessage = null;
        notifyListeners();
        return true;
      }
    }
    return false;
  }
}
