//Marko Padilla Last modified on 05/06/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'trips_model.dart';

class TripsDashboard extends StatelessWidget {
  const TripsDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TripsModel>(
      builder: (BuildContext context, Widget? child, TripsModel model) {
        return Scaffold(
          body: model.entryList.isEmpty
              ? _buildEmptyState(model)
              : _buildTripLists(context, model),
          floatingActionButton: FloatingActionButton(
            onPressed: () => model.startEditingEntry(Trip()),
            child: Icon(Icons.add),
            tooltip: 'Add Trip',
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(TripsModel model) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flight_takeoff,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No trips added yet',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add your first trip',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTripLists(BuildContext context, TripsModel model) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        // Active trips
        if (model.activeTrips.isNotEmpty) ...[
          _buildSectionHeader('Active Trips', Icons.airplanemode_active, Colors.green),
          ...model.activeTrips.map((trip) => _buildSlidableTripCard(context, trip, model)),
          SizedBox(height: 24),
        ],
        if (model.upcomingTrips.isNotEmpty) ...[
          _buildSectionHeader('Upcoming Trips', Icons.flight_takeoff, Colors.blue),
          ...model.upcomingTrips.map((trip) => _buildSlidableTripCard(context, trip, model)),
          SizedBox(height: 24),
        ],
        if (model.pastTrips.isNotEmpty) ...[
          _buildSectionHeader('Past Trips', Icons.arrow_back, Colors.grey),
          ...model.pastTrips.map((trip) => _buildSlidableTripCard(context, trip, model)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // slidable trip cards
  Widget _buildSlidableTripCard(BuildContext context, Trip trip, TripsModel model) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _deleteTrip(context, trip, model);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),

      child: _buildTripCard(context, trip, model),
    );
  }

  void _deleteTrip(BuildContext context, Trip trip, TripsModel model) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Trip'),
        content: Text('Are you sure you want to delete the trip to ${trip.destination}??'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              model.deleteEntry(trip); // Delete trip
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Trip has been deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Trip trip, TripsModel model) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          model.viewEntryDetails(trip);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination, status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      trip.destination ?? 'Unnamed Trip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: trip.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trip.status,
                      style: TextStyle(
                        color: trip.statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Dates
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    '${trip.formattedStartDate} - ${trip.formattedEndDate}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),

              if (trip.purpose != null && trip.purpose!.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.cases_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      trip.purpose!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}