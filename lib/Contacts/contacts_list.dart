import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'contacts_model.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
        model: contactsModel,
        child: ScopedModelDescendant<ContactsModel>(
            builder: (BuildContext context, Widget? child, ContactsModel model) {
              return Scaffold(
                  floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add, color: Colors.white),
                      onPressed: () async {
                        model.startEditingEntry(Contact());
                      }
                  ),

                  body: ListView.builder(
                      itemCount: model.entryList.length,
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = model.entryList[index];
                        File avatarFile = File(model.avatarFileName(contact.id));
                        bool avatarFileExists = avatarFile.existsSync();
                        return Column(
                            children: <Widget>[
                              Slidable(
                                endActionPane: ActionPane(
                                  extentRatio: .25,
                                  motion: ScrollMotion(),
                                  children: <Widget>[
                                    SlidableAction(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      label: 'Delete',
                                      icon: Icons.delete,
                                      onPressed: (ctx) =>
                                          _deleteContact(context, model, contact),
                                    )
                                  ],
                                ),

                                child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigoAccent,
                                      foregroundColor: Colors.white,
                                      backgroundImage: avatarFileExists
                                          ? FileImage(avatarFile) : null,
                                      child: avatarFileExists
                                          ? null : contact.nameAsAvatarText,
                                    ),
                                    title: contact.nameAsText,
                                    subtitle: contact.phoneAsText,
                                    onTap: () async {
                                      model.startEditingEntry(contact);
                                    }
                                ),
                              ),
                              Divider()
                            ]
                        );
                      }
                  )
              );
            }
        )
    );
  }

  Future _deleteContact(BuildContext context, ContactsModel model, Contact contact) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
              title: Text('Delete Contact'),
              content: Text('Really delete ${contact.name}?'),
              actions: [
                ElevatedButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(alertContext).pop(),
                ),
                ElevatedButton(
                  child: Text('Delete'),
                  onPressed: () async {
                    await model.deleteEntry(contact);
                    Navigator.of(alertContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 2),
                          content: Text('Contact deleted'),
                        )
                    );
                  },
                )
              ]
          );
        }
    );
  }
}

extension _ContactExtension on Contact {
  Text get nameAsAvatarText => Text((name!.substring(0, 1)).toUpperCase());

  Text? get nameAsText => name != null ?  Text(name!) : null;

  Text? get phoneAsText => phone != null ? Text(phone!) : null;
}

