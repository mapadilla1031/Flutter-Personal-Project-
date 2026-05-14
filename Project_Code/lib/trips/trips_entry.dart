//Marko Padilla Last modified on 05/06/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'trips_model.dart';

class TripsEntry extends StatelessWidget {
  final TextEditingController _destinationController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // trip type options
  final List<String> _purposeOptions = [
    'Vacation',
    'Business',
    'Emergency',
    'Wedding',
    'Graduation',
    'Family Visit',
    'Medical',
    'Conference',
    'Sports Event',
  ];

  TripsEntry({Key? key}) : super(key: key) {
    _destinationController.addListener(() {
      if (tripsModel.entryBeingEdited != null) {
        tripsModel.entryBeingEdited!.destination = _destinationController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<TripsModel>(
      builder: (BuildContext context, Widget? child, TripsModel model) {
        //use current value
        _destinationController.text = model.entryBeingEdited?.destination ?? '';
        //dropdown
        String currentPurpose = model.entryBeingEdited?.purpose ?? '';
        return Scaffold(
          appBar: AppBar(
            title: Text(
                model.entryBeingEdited?.isNew == false
                    ? 'Edit Trip'
                    : 'New Trip'
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                FocusScope.of(context).requestFocus(FocusNode());
                model.stopEditingEntry();
              },
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                // Destination field
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    labelText: 'Destination',
                    hintText: 'City, Country',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a destination';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Start date
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Start Date'),
                    subtitle: model.entryBeingEdited?.startDate != null
                        ? Text(DateFormat.yMMMMd().format(model.entryBeingEdited!.startDate!))
                        : Text('Not set'),
                    trailing: TextButton(
                      child: Text('Select'),
                      onPressed: () => _selectStartDate(context, model),
                    ),
                  ),
                ),

                SizedBox(height: 8),

                // End date
                Card(
                  child: ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('End Date'),
                    subtitle: model.entryBeingEdited?.endDate != null
                        ? Text(DateFormat.yMMMMd().format(model.entryBeingEdited!.endDate!))
                        : Text('Not set'),
                    trailing: TextButton(
                      child: Text('Select'),
                      onPressed: () => _selectEndDate(context, model),
                    ),
                  ),
                ),

                SizedBox(height: 16),

                //Dropdown field
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Purpose',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.cases_outlined),
                  ),
                  value: _purposeOptions.contains(currentPurpose) ? currentPurpose : null,
                  hint: Text('Select trip purpose'),
                  isExpanded: true,
                  items: _purposeOptions.map((String purpose) {
                    return DropdownMenuItem<String>(
                      value: purpose,
                      child: Text(purpose),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null && model.entryBeingEdited != null) {
                      model.entryBeingEdited!.purpose = value;
                    }
                  },
                ),
                SizedBox(height: 32),
                // The save and cancel buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        model.stopEditingEntry();
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      child: Text('Save'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _save(context, model),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectStartDate(BuildContext context, TripsModel model) async {
    DateTime initialDate = model.entryBeingEdited?.startDate ?? DateTime.now();

    //Date picker
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (pickedDate != null) {
      model.entryBeingEdited!.startDate = pickedDate;

      //end date if needed
      if (model.entryBeingEdited!.endDate != null &&
          model.entryBeingEdited!.endDate!.isBefore(pickedDate)) {
        model.entryBeingEdited!.endDate = pickedDate.add(const Duration(days: 1));
      }
      model.refreshUI();
    }
  }

  Future<void> _selectEndDate(BuildContext context, TripsModel model) async {
    if (model.entryBeingEdited!.startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date first')),
      );
      return;
    }
    DateTime initialDate = model.entryBeingEdited!.endDate ??
        model.entryBeingEdited!.startDate!.add(const Duration(days: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: model.entryBeingEdited!.startDate!,
      lastDate: model.entryBeingEdited!.startDate!.add(const Duration(days: 365 * 5)),
    );

    if (pickedDate != null) {
      model.entryBeingEdited!.endDate = pickedDate;
      model.refreshUI();
    }
  }

  //save trip method
  void _save(BuildContext context, TripsModel model) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (model.entryBeingEdited!.startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    if (model.entryBeingEdited!.endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an end date')),
      );
      return;
    }
    // Save the trip and return to list
    model.stopEditingEntry(save: true).then((id) {
      if (id != null && id > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save trip. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}