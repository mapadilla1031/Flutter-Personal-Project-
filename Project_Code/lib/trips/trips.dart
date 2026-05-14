//Marko Padilla Last modified on 05/05/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'trips_model.dart';
import 'trips_dashboard.dart';
import 'trips_entry.dart';
import 'trip_detail_screen.dart';

class Trips extends StatelessWidget {
  Trips({Key? key}) : super(key: key) {
    tripsModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TripsModel>(
      model: tripsModel,
      child: ScopedModelDescendant<TripsModel>(
        builder: (BuildContext context, Widget? child, TripsModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              TripsDashboard(),
              TripsEntry(),
              TripDetailScreen(),
            ],
          );
        },
      ),
    );
  }
}