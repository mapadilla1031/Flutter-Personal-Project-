import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'contacts_model.dart';

class ContactsEntry extends StatelessWidget {

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry({super.key}) {
    _nameEditingController.addListener(() {
      if (contactsModel.entryBeingEdited != null) {
        contactsModel.entryBeingEdited!.name = _nameEditingController.text;
      }
    });
    _phoneEditingController.addListener(() {
      if (contactsModel.entryBeingEdited != null) {
        contactsModel.entryBeingEdited!.phone = _phoneEditingController.text;
      }
    });
    _emailEditingController.addListener(() {
      if (contactsModel.entryBeingEdited != null) {
        contactsModel.entryBeingEdited!.email = _emailEditingController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
          builder: (BuildContext context, Widget? child, ContactsModel model) {
            // for "editing" an existing contact
            if (model.entryBeingEdited != null) {
              final contact = model.entryBeingEdited!;
              _nameEditingController.text = contact.name ?? '';
              _phoneEditingController.text = contact.phone ?? '';
              _emailEditingController.text = contact.email ?? '';
            }

            File avatarFile = model.avatarFile();

            return Scaffold(
                bottomNavigationBar: Padding(
                    padding: const EdgeInsets.all(16),

                    // cancel and save buttons
                    child: Row(
                        children: [
                          ElevatedButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              contactsModel.stopEditingEntry();
                            },
                          ),
                          const Spacer(),
                          ElevatedButton(
                            child: const Text('Save'),
                            onPressed: () => _save(context, model),
                          )
                        ]
                    )
                ),

                body: Form(
                    key: _formKey,
                    child: ListView(
                        children: [
                          ListTile(
                              title: avatarFile.existsSync() ?
                              //Image.file(avatarFile)
                              Image.memory(
                                Uint8List.fromList(
                                    avatarFile.readAsBytesSync()),
                                alignment: Alignment.center,
                                height: 200,
                                width: 200,
                                fit: BoxFit.contain,
                              )
                                  : const Text(
                                  "No avatar image for this contact"),
                              trailing: IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () => _selectAvatar(context, model)
                              )
                          ),

                          ListTile( // name
                              leading: const Icon(Icons.person),
                              title: TextFormField(
                                  decoration: const InputDecoration(
                                      hintText: 'Name'),
                                  controller: _nameEditingController,
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter a name';
                                    }
                                    return null;
                                  }
                              )
                          ),

                          ListTile( // phone
                              leading: const Icon(Icons.phone),
                              title: TextFormField(
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                    hintText: 'Phone'),
                                controller: _phoneEditingController,
                              )
                          ),

                          ListTile( // email
                            leading: const Icon(Icons.email),
                            title: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                  hintText: 'Email'),
                              controller: _emailEditingController,
                            ),
                          ),

                          ListTile( // birthday
                              leading: const Icon(Icons.today),
                              title: const Text('Birthday'),
                              subtitle: model.entryBeingEdited?.birthdayAsText,
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () async =>
                                    model.entryBeingEdited!.pickBirthday(
                                        context, model),
                              )
                          )
                        ]
                    )
                )
            );
          }
      ),
    );
  }

  Future<void> _selectAvatar(BuildContext context, ContactsModel model) {
    return showDialog(context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[

                    if (Platform.isAndroid || Platform.isIOS)
                      InkWell(
                        onTap: () async => _takePicture(dialogContext, model),
                        child: const Text('Take a picture'),
                      ),
                    if (!Platform.isAndroid && !Platform.isIOS)
                      InkWell(
                        onTap: null, // disable interaction
                        child: const Text(
                          'Take a picture (not available)',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    const Divider(),

                    InkWell(
                      child: const Text('Select From Gallery'),
                      onTap: () async => _pickImage(dialogContext, model),
                    ),
                  ],
                )
            ),
          );
        }
    );
  }

  void _takePicture(BuildContext context, ContactsModel model) async {
    final ImagePicker picker = ImagePicker();
    final XFile? cameraImage = await picker.pickImage(
        source: ImageSource.camera);
    if (cameraImage != null) {
      final File file = File(cameraImage.path);
      await file.copy(model.avatarTempFileName());
      model.refreshUI();
    }
    Navigator.of(context).pop(); // Close dialog
  }

  void _pickImage(BuildContext context, ContactsModel model) async {
    final ImagePicker picker = ImagePicker();
    final XFile? galleryImage = await picker.pickImage(
        source: ImageSource.gallery);
    if (galleryImage != null) {
      final File file = File(galleryImage.path);
      await file.copy(model.avatarTempFileName());
      imageCache.clear();
      model.refreshUI();
    }
    Navigator.of(context).pop(); // close dialog
  }

  void _save(BuildContext context, ContactsModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), content: Text('Contact saved'),
        )
    );
  }
}

extension _ContactExtension on Contact {

  Text? get birthdayAsText => hasBirthday
      ? Text(formattedBirthday ?? '') : null;

  Future<void> pickBirthday(BuildContext context, ContactsModel model) async {
    final date = await _selectDate(context, model.entryBeingEdited!.birthday);
    if (date != null) {
      model.entryBeingEdited!.birthday = date;
      model.refreshUI();
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) async {
    DateTime? initialDate = date ?? DateTime.now();
    DateTime? picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    return picked;
  }
}

