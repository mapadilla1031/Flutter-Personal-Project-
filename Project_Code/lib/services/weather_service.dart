//Marko Padilla Last modified on 05/07/25
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String baseUrl = 'https://api.open-meteo.com/v1/forecast';

  // get weather for a location by city name
  static Future<String> getWeatherInfo(String cityName) async {
    try {
      // Get coordinates for the city
      final coordinates = _getCityCoordinates(cityName);
      if (coordinates == null) {
        return 'Not available';
      }

      // URL with parameters for Fahrenheit temperature
      final url = '$baseUrl?latitude=${coordinates['lat']}&longitude=${coordinates['lng']}'
          '&current_weather=true&temperature_unit=fahrenheit&timezone=auto';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        return 'Not available';
      }

      // Parse the json response
      final data = json.decode(response.body);

      // Get current temperature only
      final currentTemp = data['current_weather']['temperature'];

      // Return just the temperature with °F
      return '${currentTemp.round()}°F';
    } catch (e) {
      print('Error getting weather: $e');
      return 'Not available';
    }
  }

  // Helper to determine weather icon based only on temperature
  static IconData getWeatherIcon(int temp) {
    // Temperature icon based on how warm,cold it is
    if (temp >= 80) return Icons.wb_sunny;
    if (temp >= 70) return Icons.wb_twilight;
    if (temp >= 50) return Icons.thermostat;
    if (temp >= 32) return Icons.ac_unit;
    return Icons.snowing;
  }

  // coordinates for common cities
  static Map<String, double>? _getCityCoordinates(String cityName) {
    final name = cityName.split(',').first.trim().toLowerCase();

    final Map<String, Map<String, double>> coordinates = {
      'new york': {'lat': 40.7128, 'lng': -74.0060},
      'los angeles': {'lat': 34.0522, 'lng': -118.2437},
      'chicago': {'lat': 41.8781, 'lng': -87.6298},
      'dallas': {'lat': 32.7767, 'lng': -96.7970},
      'miami': {'lat': 25.7617, 'lng': -80.1918},
      'seattle': {'lat': 47.6062, 'lng': -122.3321},
      'san francisco': {'lat': 37.7749, 'lng': -122.4194},
      'denver': {'lat': 39.7392, 'lng': -104.9903},
      'boston': {'lat': 42.3601, 'lng': -71.0589},
      'washington': {'lat': 38.9072, 'lng': -77.0369},
      'las vegas': {'lat': 36.1699, 'lng': -115.1398},
      'phoenix': {'lat': 33.4484, 'lng': -112.0740},
      'houston': {'lat': 29.7604, 'lng': -95.3698},
      'austin': {'lat': 30.2672, 'lng': -97.7431},
      'atlanta': {'lat': 33.7490, 'lng': -84.3880},
      'orlando': {'lat': 28.5383, 'lng': -81.3792},
      'el paso': {'lat': 31.7619, 'lng': -106.4850},
    };

    // matches or partial matches
    for (var city in coordinates.keys) {
      if (name.contains(city) || city.contains(name)) {
        return coordinates[city];
      }
    }

    // Default to El Paso if no match
    return {'lat': 31.7619, 'lng': -106.4850};
  }
}