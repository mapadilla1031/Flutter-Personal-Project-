//Marko Padilla Last modified on 05/06/25
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:scoped_model/scoped_model.dart';
import 'trips/trips.dart';
import 'trips/trips_model.dart';
import 'documents/documents.dart';
import 'trips/trip_map.dart';

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    tz.initializeTimeZones();

    runApp(TripTapApp());
  }
  startMeUp();
}

class TripTapApp extends StatelessWidget {
  static const _tabs = [
    {'icon': Icons.coffee_outlined, 'name': 'Dashboard'},
    {'icon': Icons.business_center_sharp, 'name': 'Documents'},
    {'icon': Icons.map, 'name': 'Pin Map'},
  ];

  TripTapApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripTap',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        primaryColor: Colors.blue,
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blue,
          background: Colors.white,
          surface: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.blue,
          indicatorColor: Colors.blue,
        ),
      ),
      home: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('TripTap'),
            bottom: TabBar(
              tabs: _tabs.map((tab) => Tab(
                icon: Icon(tab['icon'] as IconData),
                text: tab['name'] as String,
              )).toList(),
            ),
          ),
          body: TabBarView(
            children: _tabs.map((tab) {
              final name = tab['name'] as String;
              if (name == 'Dashboard') {
                return Trips();
              } else if (name == 'Documents') {
                return Documents();
              } else if (name == 'Pin Map') {
                if (tripsModel.entryList.isEmpty) {
                  tripsModel.loadData();
                }
                return ScopedModel<TripsModel>(
                  model: tripsModel,
                  child: TripMap(),
                );
              } else {
                return Center(child: Text(name));
              }
            }).toList(),
          ),
        ),
      ),
    );
  }
}