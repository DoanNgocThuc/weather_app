// services/weather_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = dotenv.env['WEATHER_URL'] ?? '';
  final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no');
    final response = await http.get(url);
    if (response.statusCode == 200) {

      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(_extractMessage(response.body, 'Failed to load weather data'));
    }
  }

  Future<Map<String, dynamic>> getForecast(String city, int days) async {
    final url = Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=$days&aqi=no&alerts=no&hour=no&lang=no&tp=no');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      print("Success");
      // print('DEBUG: Forecast response: ${response.body}');
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(_extractMessage(response.body, 'Failed to load forecast data'));
    }
  }

  // NEW: coordinates support (WeatherAPI supports q=lat,lon)
  Future<Map<String, dynamic>> getWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse('$_baseUrl/current.json?key=$_apiKey&q=$lat,$lon&aqi=no');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(_extractMessage(response.body, 'Failed to load weather data by coordinates'));
    }
  }

  Future<Map<String, dynamic>> getForecastByCoords(double lat, double lon, int days) async {
    final url = Uri.parse('$_baseUrl/forecast.json?key=$_apiKey&q=$lat,$lon&days=$days&aqi=no&alerts=no');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception(_extractMessage(response.body, 'Failed to load forecast data by coordinates'));
    }
  }

  // Optional: make error messages friendlier if WeatherAPI returns an "error" object
  String _extractMessage(String body, String fallback) {
    try {
      final m = jsonDecode(body);
      if (m is Map && m['error'] is Map && m['error']['message'] is String) {
        return m['error']['message'] as String;
      }
    } catch (_) {}
    return fallback;
  }
}
