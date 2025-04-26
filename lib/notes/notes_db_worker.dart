import 'package:flutter/material.dart';
import 'package:flutterbook/base_model.dart';
import 'notes_model.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

abstract interface class NotesDBWorker implements EntryDBWorker<Note> {
  // ✅ You can switch this to SQLite now if ready
  static final NotesDBWorker db = _SqfliteNotesDBWorker._();
  // static final NotesDBWorker db = _MemoryNotesDBWorker._();

  Future<int> create(Note note);
  Future<void> update(Note note);
  Future<void> delete(int id);
  Future<Note?> get(int id);
  Future<List<Note>> getAll();
}

/// 🧠 Old in-memory DB for testing (optional)
/*
class _MemoryNotesDBWorker implements NotesDBWorker {
  final _notes = <Note>[];
  var _nextId = 1;

  _MemoryNotesDBWorker._() {
    var note1 = Note()
      ..title = 'Exercise: P2.3 Persistence TEST change'
      ..content = 'Code database.'
      ..color = Colors.blue;
    create(note1);

    var note2 = Note()
      ..title = 'Demo Note'
      ..content = 'This is a second note.'
      ..color = Colors.green;
    create(note2);
  }

  @override
  Future<int> create(Note note) async {
    note = note.clone();
    note.id = _nextId++;
    _notes.add(note);
    print('Added: $note');
    return note.id;
  }

  @override
  Future<void> update(Note note) async {
    var old = await get(note.id);
    if (old != null) {
      old
        ..title = note.title
        ..content = note.content
        ..color = note.color;
    }
    print('Updated: $note');
  }

  @override
  Future<void> delete(int id) async =>
      _notes.removeWhere((n) => n.id == id);

  @override
  Future<Note?> get(int id) async {
    try {
      return _notes.firstWhere((note) => note.id == id).clone();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Note>> getAll() async =>
      _notes.map((n) => n.clone()).toList();
}
*/

class _SqfliteNotesDBWorker implements NotesDBWorker {
  static const String DB_NAME = 'notes.db';
  static const String TBL_NAME = 'notes';
  static const String KEY_ID = '_id';
  static const String KEY_TITLE = 'title';
  static const String KEY_CONTENT = 'content';
  static const String KEY_COLOR = 'color';

  Database? _db;

  _SqfliteNotesDBWorker._();

  Future<Database> get database async =>
      _db ??= await _init();

  Future<Database> _init() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    String path = join(docsDir.path, DB_NAME);
    return await openDatabase(
      path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $TBL_NAME (
            $KEY_ID INTEGER PRIMARY KEY,
            $KEY_TITLE TEXT,
            $KEY_CONTENT TEXT,
            $KEY_COLOR TEXT
          )
        ''');
      },
    );
  }

  @override
  Future<int> create(Note note) async {
    Database db = await database;
    int id = await db.rawInsert(
      'INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_CONTENT, $KEY_COLOR) VALUES (?, ?, ?)',
      [note.title, note.content, note.colorName],
    );
    return id;
  }

  @override
  Future<void> update(Note note) async {
    Database db = await database;
    await db.update(
      TBL_NAME,
      _noteToMap(note), // we'll define this helper function below
      where: '$KEY_ID = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(
      TBL_NAME,
      where: '$KEY_ID = ?',
      whereArgs: [id],
    );
  }
  @override
  Future<Note?> get(int id) async {
    Database db = await database;
    var values = await db.query(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
    return values.isEmpty ? null : _noteFromMap(values.first);
  }

  @override
  Future<List<Note>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME);
    return values.isNotEmpty ? values.map((m) => _noteFromMap(m)).toList() : [];
  }
  Note _noteFromMap(Map map) {
    return Note()
      ..id = map[KEY_ID]
      ..title = map[KEY_TITLE]
      ..content = map[KEY_CONTENT]
      ..colorName = map[KEY_COLOR];
  }
  Map<String, dynamic> _noteToMap(Note note) {
    return Map<String, dynamic>()
      ..[KEY_ID] = note.id
      ..[KEY_TITLE] = note.title
      ..[KEY_CONTENT] = note.content
      ..[KEY_COLOR] = note.colorName;
  }

}