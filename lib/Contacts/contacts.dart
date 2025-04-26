import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_entry.dart';
import 'contacts_list.dart';
import 'contacts_model.dart';

Future<void> setAvatarDirectory() async {
  Avatar.avatarDir = await getApplicationDocumentsDirectory();
}

class Contacts extends StatelessWidget {

  Contacts({super.key}) {
    contactsModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
            builder: (BuildContext context, Widget? child, ContactsModel model) {
              return IndexedStack(
                index: model.stackIndex,
                children: <Widget>[ ContactsList(), ContactsEntry()],
              );
            }
        )
    );
  }
}

