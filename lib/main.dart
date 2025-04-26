//Marko Padilla Last modified on 04/24/25
import 'package:flutter/material.dart';
import 'Contacts/contacts.dart';
import 'notes/notes.dart';
import 'tasks/tasks.dart';
import 'expenses/expenses.dart';

void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await setAvatarDirectory();

    runApp(FlutterBook());
  }
  startMeUp();
}

class FlutterBook extends StatelessWidget {
  static const _tabs = [
    {'icon': Icons.date_range, 'name': 'Appointments'},
    {'icon': Icons.contacts, 'name': 'Contacts'},
    {'icon': Icons.note, 'name': 'Notes'},
    {'icon': Icons.assignment_turned_in, 'name': 'Tasks'},
    {'icon': Icons.attach_money, 'name': 'Expenses'}, //  new tab
  ];

  FlutterBook({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterBook',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DefaultTabController(
        length: _tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text('FlutterBook'),
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
              if (name == 'Notes') {
                return Notes();
              } else if (name == 'Tasks') {
                return Tasks();
              } else if (name == 'Appointments') {
                return Center(child: Text('Appointments'));
              } else if (name == 'Contacts') {
                return Contacts();
              } else if (name == 'Expenses') {
                return Expenses();
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