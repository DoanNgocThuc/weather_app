import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  final String _baseUrl = dotenv.env['WEATHER_URL'] ?? '';
  final String _apiKey = dotenv.env['WEATHER_API_KEY'] ?? '';

  /// Fetch weather by city name
  Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    final url = Uri.parse(
      '$_baseUrl/current.json?key=$_apiKey&q=$city&aqi=no',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load weather data: ${response.body}');
    }
  }

  /// Fetch forecast by city name (optional)
  Future<Map<String, dynamic>> getForecast(String city, {int days = 3}) async {
    final url = Uri.parse(
      '$_baseUrl/forecast.json?key=$_apiKey&q=$city&days=$days&aqi=no&alerts=no',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load forecast data: ${response.body}');
    }
  }
}
