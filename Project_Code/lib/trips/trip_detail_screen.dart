//Marko Padilla Last modified on 05/07/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../services/timezone_service.dart';
import '../services/weather_service.dart';
import 'trips_model.dart';

class TripDetailScreen extends StatefulWidget {
  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  String _destinationTime = 'Loading...';
  String _destinationDate = '';
  String _destinationTimezone = '';
  String _weatherInfo = 'Loading...'; // Weather data field
  int _currentTemp = 70; // Default temp

  void _loadDestinationTime(String? destination) {
    if (destination == null || destination.isEmpty) return;

    TimezoneService.getDateAndTime(destination).then((data) {
      if (mounted) {
        setState(() {
          _destinationTime = data['time'] ?? 'Unknown';
          _destinationDate = data['date'] ?? '';
          _destinationTimezone = data['timezone'] ?? '';
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _destinationTime = 'Unable to load';
        });
      }
    });
  }

  //  load only current temperature
  void _loadWeatherInfo(String? destination) {
    if (destination == null || destination.isEmpty) return;

    WeatherService.getWeatherInfo(destination).then((data) {
      if (mounted) {
        setState(() {
          _weatherInfo = data;
          if (data.contains('°F')) {
            try {
              String tempStr = data.split('°F')[0].trim();
              _currentTemp = int.parse(tempStr);
            } catch (e) {
              _currentTemp = 70; // Default
            }
          }
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _weatherInfo = 'Not available';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TripsModel>(
      builder: (BuildContext context, Widget? child, TripsModel model) {
        final trip = model.entryBeingEdited;

        if (trip == null) {
          return Center(
            child: Text('No trip selected'),
          );
        }

        // Load destination time when trip details are shown
        if (_destinationTime == 'Loading...' && trip.destination != null) {
          _loadDestinationTime(trip.destination);
        }

        // Load weather info when details are shown
        if (_weatherInfo == 'Loading...' && trip.destination != null) {
          _loadWeatherInfo(trip.destination);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(trip.destination ?? 'Trip Details'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                model.stackIndex = 0; //dashobard
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  model.stackIndex = 1; // Go to edit screen
                },
              ),
              // Refresh button for the weather
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  if (trip.destination != null) {
                    setState(() {
                      _weatherInfo = 'Loading...';
                    });
                    _loadWeatherInfo(trip.destination);
                  }
                },
                tooltip: 'Refresh temperature',
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                color: Colors.blue.withOpacity(0.3),
                child: Center(
                  child: Icon(
                    Icons.flight_takeoff,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                color: Colors.grey[100],
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Trip info using grid view
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildInfoCard(
                      title: 'Destination',
                      value: trip.destination ?? 'Not specified',
                      icon: Icons.place,
                      color: Colors.green,
                    ),
                    _buildInfoCard(
                      title: 'Travel Dates',
                      value: '${trip.formattedStartDate}\nto ${trip.formattedEndDate}',
                      icon: Icons.calendar_today,
                      color: Colors.green,
                    ),
                    _buildInfoCard(
                      title: 'Local Time',
                      value: _destinationTime,
                      subtitle: _destinationDate,
                      icon: Icons.access_time,
                      color: Colors.green,
                    ),

                    _buildInfoCard(
                      title: 'Purpose',
                      value: trip.purpose ?? 'Not specified',
                      icon: Icons.cases_outlined,
                      color: Colors.green,
                    ),
                    _buildInfoCard(
                      title: 'Local Weather',
                      value: _weatherInfo,
                      icon: _weatherInfo == 'Loading...' ? Icons.thermostat :
                      WeatherService.getWeatherIcon(_currentTemp),
                      color: Colors.blue,
                    ),
                    _buildInfoCard(
                      title: 'Status',
                      value: trip.status,
                      icon: Icons.info_outline,
                      color: trip.statusColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: color,
              ),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}