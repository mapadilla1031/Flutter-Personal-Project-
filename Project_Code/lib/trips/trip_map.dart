//Marko Padilla Last modified on 05/06/25
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import 'trips_model.dart';
import 'dart:async';

class TripMap extends StatefulWidget {
  @override
  _TripMapState createState() => _TripMapState();
}

class _TripMapState extends State<TripMap> {
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _initialPosition = CameraPosition(target: LatLng(37.0902, -95.7129), // using USA middle
    zoom: 3.5,
  );

  // markers to display on the map
  Set<Marker> _markers = {};

  //common city coordinates
  final Map<String, LatLng> _cityCoordinates = {
    'new york': LatLng(40.7128, -74.0060),
    'los angeles': LatLng(34.0522, -118.2437),
    'chicago': LatLng(41.8781, -87.6298),
    'dallas': LatLng(32.7767, -96.7970),
    'miami': LatLng(25.7617, -80.1918),
    'seattle': LatLng(47.6062, -122.3321),
    'san francisco': LatLng(37.7749, -122.4194),
    'denver': LatLng(39.7392, -104.9903),
    'boston': LatLng(42.3601, -71.0589),
    'washington': LatLng(38.9072, -77.0369),
    'las vegas': LatLng(36.1699, -115.1398),
    'phoenix': LatLng(33.4484, -112.0740),
    'houston': LatLng(29.7604, -95.3698),
    'austin': LatLng(30.2672, -97.7431),
    'atlanta': LatLng(33.7490, -84.3880),
    'orlando': LatLng(28.5383, -81.3792),
    'el paso': LatLng(31.7619, -106.4850),
  };

  void _createMarkers(TripsModel model) {
    Set<Marker> newMarkers = {};
    // the active trips
    for (Trip trip in model.activeTrips) {
      if (trip.destination != null) {
        LatLng? position = _getCoordinatesForDestination(trip.destination!);
        if (position != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId('active_${trip.id}'),
              position: position,
              infoWindow: InfoWindow(
                title: trip.destination,
                snippet: '${trip.formattedStartDate} - ${trip.formattedEndDate}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          );
        }
      }
    }

    // past trips
    for (Trip trip in model.pastTrips) {
      if (trip.destination != null) {
        LatLng? position = _getCoordinatesForDestination(trip.destination!);
        if (position != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId('past_${trip.id}'),
              position: position,
              infoWindow: InfoWindow(
                title: trip.destination,
                snippet: '${trip.formattedStartDate} - ${trip.formattedEndDate}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
            ),
          );
        }
      }
    }

    // upcoming trips
    for (Trip trip in model.upcomingTrips) {
      if (trip.destination != null) {
        LatLng? position = _getCoordinatesForDestination(trip.destination!);
        if (position != null) {
          newMarkers.add(
            Marker(
              markerId: MarkerId('upcoming_${trip.id}'),
              position: position,
              infoWindow: InfoWindow(
                title: trip.destination,
                snippet: '${trip.formattedStartDate} - ${trip.formattedEndDate}',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
            ),
          );
        }
      }
    }

    setState(() {
      _markers = newMarkers;
    });

    if (_markers.isNotEmpty && _controller.isCompleted) {
      _fitAllMarkers();
    }
  }

  // Get the coordinates for a dest name
  LatLng? _getCoordinatesForDestination(String destination) {
    // convert to lower if needed from user input
    String lowerDestination = destination.toLowerCase();

    // Look for matche
    for (String cityName in _cityCoordinates.keys) {
      if (lowerDestination.contains(cityName)) {
        return _cityCoordinates[cityName];
      }
    }
    print('No coordinates found for: $destination');
    return null;
  }

  // Adjust map camera
  Future<void> _fitAllMarkers() async {
    if (_markers.isEmpty) return;
    GoogleMapController controller = await _controller.future;

    // Calc bounds , markers
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (Marker marker in _markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }

    // Add some padding
    double padding = 2.0; // degrees
    minLat -= padding;
    maxLat += padding;
    minLng -= padding;
    maxLng += padding;

    // Move camera to show all the markers
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0, // padding in pix
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TripsModel>(
      builder: (BuildContext context, Widget? child, TripsModel model) {
        return Scaffold(
          body: Column(
            children: [

              Container(
                width: double.infinity,
                color: Colors.grey[100],
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Map',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[800],
                      ),
                    ),

                  ],
                ),
              ),

              // Map plus add in zoom, features
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  compassEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    _createMarkers(model);
                  },
                ),
              ),

              Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLegendItem(Colors.green, 'Active'),
                    _buildLegendItem(Colors.purple, 'Past'),
                    _buildLegendItem(Colors.blue, 'Upcoming'),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _createMarkers(model),
            child: Icon(Icons.redo),
            tooltip: 'Refresh Map',
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}