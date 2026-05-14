//Marko Padilla Last modified on 05/02/25
import 'package:flutter/material.dart';
import '../base_model.dart';
import 'trips_db_worker.dart';
import 'package:intl/intl.dart';

final TripsModel tripsModel = TripsModel();

class TripsModel extends BaseModel<Trip> {
  //upcoming trips
  List<Trip> get upcomingTrips {
    final now = DateTime.now();
    return entryList.where((trip) {
      return trip.hasStartDate &&
          trip.startDate!.isAfter(now);
    }).toList();
  }

  //active trips
  List<Trip> get activeTrips {
    final now = DateTime.now();
    return entryList.where((trip) {
      return trip.hasStartDate &&
          trip.hasEndDate &&
          trip.startDate!.isBefore(now) &&
          trip.endDate!.isAfter(now);
    }).toList();
  }

  //past trips
  List<Trip> get pastTrips {
    final now = DateTime.now();
    return entryList.where((trip) {
      return trip.hasEndDate &&
          trip.endDate!.isBefore(now);
    }).toList();
  }

  TripsModel() : super(TripsDBWorker.db);
}

class Trip extends Entry with DateMixin {
  String? destination;
  String? purpose;

  Trip({
    super.id = Entry.NO_ID,
    this.destination,
    DateTime? startDate,
    DateTime? endDate,
    this.purpose,
  }) {
    this.startDate = startDate ?? DateTime.now();
    this.endDate = endDate ?? (startDate?.add(const Duration(days: 7)) ?? DateTime.now().add(const Duration(days: 7)));
  }

  bool get hasStartDate => startDate != null;
  bool get hasEndDate => endDate != null;

  String get formattedStartDate => hasStartDate
      ? DateFormat.yMMMMd('en_US').format(startDate!)
      : 'Not specified';

  String get formattedEndDate => hasEndDate
      ? DateFormat.yMMMMd('en_US').format(endDate!)
      : 'Not specified';

  String get status {
    final now = DateTime.now();
    if (!hasStartDate || !hasEndDate) return 'Pending';
    if (now.isBefore(startDate!)) return 'Upcoming';
    if (now.isAfter(endDate!)) return 'Past';
    return 'Active';
  }

  Color get statusColor {
    switch (status) {
      case 'Upcoming':
        return Colors.blue;
      case 'Active':
        return Colors.green;
      case 'Past':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}

//handle dates
mixin DateMixin {
  DateTime? startDate;
  DateTime? endDate;

  DateTime? get startDateAsDateTime => startDate;
  DateTime? get endDateAsDateTime => endDate;

  int? get startDateInUnix => startDate?.millisecondsSinceEpoch;
  set startDateInUnix(int? value) {
    if (value != null && value > 0) {
      startDate = DateTime.fromMillisecondsSinceEpoch(value);
    } else {
      startDate = null;
    }
  }

  int? get endDateInUnix => endDate?.millisecondsSinceEpoch;
  set endDateInUnix(int? value) {
    if (value != null && value > 0) {
      endDate = DateTime.fromMillisecondsSinceEpoch(value);
    } else {
      endDate = null;
    }
  }
}