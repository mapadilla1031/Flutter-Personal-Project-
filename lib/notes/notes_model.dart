

import 'package:flutter/material.dart';
import '../base_model.dart';
import 'notes_db_worker.dart';

final NotesModel notesModel = NotesModel();

class NotesModel extends BaseModel<Note> {

  NotesModel(): super(NotesDBWorker.db);

  /// Returns the color of the note currently being edited,
  /// or `null` if no note is being edited.
  Color? get color => entryBeingEdited?.color;

  /// Sets the color of the current note and notifies listeners.
  set color(Color? color) {
    assert(entryBeingEdited != null);
    entryBeingEdited!.color = color;
    notifyListeners();
  }
}

class Note extends Entry {

  String? title;
  String? content;
  Color? color;

  Note({super.id = Entry.NO_ID, this.title, this.content, this.color});

  String? get colorName {
    for (var entry in _colorMap.entries) {
      if (entry.value == color) {
        return entry.key;
      }
    }
    return null;
  }

  set colorName(String? name) => color = _colorMap[name];

  Note clone() => Note(id: id, title: title, content: content, color: color);

  static List<Color> get allColors => _colorMap.values.toList();

  @override
  String toString() => '{id=$id, title=$title, content=$content, color=$color}';

  static const _colorMap = {
    'red': Colors.red,
    'green': Colors.green,
    'blue': Colors.blue,
    'yellow': Colors.yellow,
    'grey': Colors.grey,
    'purple': Colors.purple,
  };
}

