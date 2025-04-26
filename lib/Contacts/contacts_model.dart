

import 'dart:io';
import 'package:path/path.dart' as path;
import 'contacts_db_worker.dart';
import "../base_model.dart";

ContactsModel contactsModel = ContactsModel();

class ContactsModel extends BaseModel<Contact> with Avatar<Contact> {
  ContactsModel(): super(ContactsDBWorker.db);

  @override
  void startEditingEntry(Contact entry) async {
    deleteAvatarTempFile();
    super.startEditingEntry(entry);
  }

  @override
  Future<int?> stopEditingEntry({bool save = false}) async {
    var id = await super.stopEditingEntry(save: save);
    // remove or rename temp avatar file.
    if (save) {
      renameAvatarTempFile(id!);
    } else {
      deleteAvatarTempFile();
    }
    return id;
  }
}

class Contact extends Entry with DateMixin {
  String? name;
  String? phone;
  String? email;
  Contact({super.id = Entry.NO_ID, this.name, this.phone, this. email,
    DateTime? birthday}) {
    date = birthday;
  }

  // better names for properties inherited from DateEntry mixin.
  bool get hasBirthday  => hasDate;
  DateTime? get birthday  => date;
  set birthday (DateTime? birthday ) => date = birthday ;
  int? get birthdayInUnix => dateInUnix;
  set birthdayInUnix(int? millis) => dateInUnix = millis;
  String? get formattedBirthday => formattedDate;

  @override
  String toString() => '{id=$id, name=$name, phone=$phone, email=$email, '
      'birthday=$birthday}';
}

mixin Avatar<T extends Entry> on BaseModel<T> {
  static late Directory avatarDir;

  File avatarTempFile() {
    return File(avatarTempFileName());
  }

  String avatarTempFileName() {
    return path.join(avatarDir.path, 'avatar');
  }

  String avatarFileName(int id) {
    return path.join(avatarDir.path, id.toString());
  }

  void renameAvatarTempFile(int id) {
    File avatarFile = avatarTempFile();
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(avatarFileName(id));
    }
  }

  void deleteAvatarTempFile() {
    File avatarFile = avatarTempFile();
    if (avatarFile.existsSync()) {
      avatarFile.deleteSync();
    }
  }

  File avatarFile() {
    File avatarFile = avatarTempFile();
    if (!avatarFile.existsSync()
        && entryBeingEdited != null
        && !entryBeingEdited!.isNew) {
      avatarFile = File(avatarFileName(entryBeingEdited!.id));
    }
    return avatarFile;
  }
}

