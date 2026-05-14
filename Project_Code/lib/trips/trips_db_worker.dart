//Marko Padilla Last modified on 05/06/25
import 'package:sqflite/sqflite.dart';
import '../base_model.dart';
import 'trips_model.dart';

class TripsDBWorker implements EntryDBWorker<Trip> {
  static final TripsDBWorker db = TripsDBWorker._();

  static const String DB_NAME = 'trips.db';
  static const String TBL_NAME = 'trips';
  static const String KEY_ID = 'id';
  static const String KEY_DESTINATION = 'destination';
  static const String KEY_START_DATE = 'startDate';
  static const String KEY_END_DATE = 'endDate';
  static const String KEY_PURPOSE = 'purpose';

  Database? _db;

  TripsDBWorker._();

  Future<Database> get database async => _db ??= await _init();

  Future<Database> _init() async {
    return await openDatabase(
      DB_NAME,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS $TBL_NAME ('
              '$KEY_ID INTEGER PRIMARY KEY,'
              '$KEY_DESTINATION TEXT,'
              '$KEY_START_DATE INTEGER,'
              '$KEY_END_DATE INTEGER,'
              '$KEY_PURPOSE TEXT'
              ')',
        );
      },
    );
  }

  @override
  Future<int> create(Trip trip) async {
    try {
      Database db = await database;

      // Validate data before it is inserted
      if (trip.startDateInUnix == null || trip.endDateInUnix == null) {
        print('Error: Start date or end date is null');
        return -1; // Error
      }

      return await db.rawInsert(
        'INSERT INTO $TBL_NAME ($KEY_DESTINATION, $KEY_START_DATE, $KEY_END_DATE, $KEY_PURPOSE) '
            'VALUES (?, ?, ?, ?)',
        [
          trip.destination,
          trip.startDateInUnix,
          trip.endDateInUnix,
          trip.purpose,
        ],
      );
    } catch (e) {
      print('Error creating trip: $e');
      return -1; // error
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      Database db = await database;
      // print('Attempting to delete trip with ID: $id');
      int rowsDeleted = await db.delete(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
      // print('Deleted $rowsDeleted row(s) with ID: $id'); // testing
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Future<Trip?> get(int id) async {
    try {
      Database db = await database;
      var values =
      await db.query(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
      return values.isEmpty ? null : _tripFromMap(values.first);
    } catch (e) {
      print('Error $e');
      return null;
    }
  }

  @override
  Future<List<Trip>> getAll() async {
    try {
      Database db = await database;
      var values = await db.query(TBL_NAME);
      print('Retrieved ${values.length} trips from database');
      return values.isNotEmpty
          ? values.map((m) => _tripFromMap(m)).toList()
          : [];
    } catch (e) {
      print('Error $e');
      return [];
    }
  }

  @override
  Future<void> update(Trip trip) async {
    try {
      Database db = await database;
      await db.update(
        TBL_NAME,
        _tripToMap(trip),
        where: '$KEY_ID = ?',
        whereArgs: [trip.id],
      );
    } catch (e) {
      print('Error $e');
    }
  }

  Trip _tripFromMap(Map<String, dynamic> map) {
    return Trip(
      id: map[KEY_ID],
      destination: map[KEY_DESTINATION],
      purpose: map[KEY_PURPOSE],
    )
      ..startDateInUnix = map[KEY_START_DATE]
      ..endDateInUnix = map[KEY_END_DATE];
  }

  Map<String, dynamic> _tripToMap(Trip trip) => <String, dynamic>{
    KEY_ID: trip.id,
    KEY_DESTINATION: trip.destination,
    KEY_START_DATE: trip.startDateInUnix,
    KEY_END_DATE: trip.endDateInUnix,
    KEY_PURPOSE: trip.purpose,
  };
}