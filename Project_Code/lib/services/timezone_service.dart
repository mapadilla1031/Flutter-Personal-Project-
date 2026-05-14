import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';

class TimezoneService {
  static const String baseUrl = 'http://worldtimeapi.org/api/timezone';

  // Get the date and time for a location
  static Future<Map<String, String>> getDateAndTime(String location) async {
    try {
      String apiLocation = _mapCityToTimezone(location);
      final response = await http.get(Uri.parse('$baseUrl/$apiLocation'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final DateTime time = DateTime.parse(data['datetime']);

        return {
          'date': DateFormat.yMMMMd().format(time),
          'time': DateFormat.jm().format(time),
          'timezone': data['timezone'],
          'abbreviation': data['abbreviation'],
        };
      }
      return _getFallbackDateAndTime(location);
    } catch (e) {
      return _getFallbackDateAndTime(location);
    }
  }

  // Get current time for a location
  static Future<String> getCurrentTime(String location) async {
    try {
      final timeData = await getDateAndTime(location);
      return timeData['time'] ?? 'Unknown';
    } catch (e) {
      return DateFormat.jm().format(DateTime.now());
    }
  }

  // Fallback when API fails
  static Map<String, String> _getFallbackDateAndTime(String location) {
    try {
      String tzLocation = _findBestTimezoneMatch(location);
      if (tzLocation.isNotEmpty) {
        final locationTime = tz.TZDateTime.now(tz.getLocation(tzLocation));
        return {
          'date': DateFormat.yMMMMd().format(locationTime),
          'time': DateFormat.jm().format(locationTime),
          'timezone': tzLocation,
          'abbreviation': '',
        };
      }
    } catch (e) {}

    // just use default local time if time not available
    final now = DateTime.now();
    return {
      'date': DateFormat.yMMMMd().format(now),
      'time': DateFormat.jm().format(now),
      'timezone': 'Local',
      'abbreviation': '',
    };
  }

  // Map city name to timezone
  static String _mapCityToTimezone(String city) {
    String cleanCity = city.trim().toLowerCase();

    // Common city
    Map<String, String> cityMap = {
      'dallas': 'America/Chicago',
      'el paso': 'America/Denver',
      'new york': 'America/New_York',
      'los angeles': 'America/Los_Angeles',
      'chicago': 'America/Chicago',
      'denver': 'America/Denver',
      'phoenix': 'America/Phoenix',
      'london': 'Europe/London',
      'paris': 'Europe/Paris',
      'berlin': 'Europe/Berlin',
      'rome': 'Europe/Rome',
      'madrid': 'Europe/Madrid',
      'tokyo': 'Asia/Tokyo',
      'beijing': 'Asia/Shanghai',
      'sydney': 'Australia/Sydney',
      'auckland': 'Pacific/Auckland',
    };

    //  city matches
    for (var entry in cityMap.entries) {
      if (cleanCity.contains(entry.key)) {
        return entry.value;
      }
    }

    // country matches
    Map<String, String> countryMap = {
      'usa': 'America/New_York',
      'united states': 'America/New_York',
      'uk': 'Europe/London',
      'england': 'Europe/London',
      'france': 'Europe/Paris',
      'germany': 'Europe/Berlin',
      'italy': 'Europe/Rome',
      'spain': 'Europe/Madrid',
      'japan': 'Asia/Tokyo',
      'china': 'Asia/Shanghai',
      'australia': 'Australia/Sydney',
      'new zealand': 'Pacific/Auckland',
    };

    for (var entry in countryMap.entries) {
      if (cleanCity.contains(entry.key)) {
        return entry.value;
      }
    }

    return 'Etc/UTC';
  }

  // Find best timezone match from available options
  static String _findBestTimezoneMatch(String location) {
    String cleanLocation = location.trim().toLowerCase();

    // mapped timezone first
    String mappedTimezone = _mapCityToTimezone(cleanLocation);
    if (mappedTimezone != 'Etc/UTC') {
      return mappedTimezone;
    }

    //available timezones
    List<String> availableLocations = tz.timeZoneDatabase.locations.keys.toList();
    for (String tzLocation in availableLocations) {
      if (tzLocation.toLowerCase().contains(cleanLocation)) {
        return tzLocation;
      }
    }

    return '';
  }
}