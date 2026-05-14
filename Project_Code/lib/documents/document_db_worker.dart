//Marko Padilla Last modified on 05/06/25
import 'package:sqflite/sqflite.dart';
import '../base_model.dart';
import 'documents_model.dart';

class DocumentDBWorker implements EntryDBWorker<Document> {
  static final DocumentDBWorker db = DocumentDBWorker._();

  static const String DB_NAME = 'documents.db';
  static const String TBL_NAME = 'documents';
  static const String KEY_ID = 'id';
  static const String KEY_FILE_PATH = 'filePath';
  static const String KEY_DATE_ADDED = 'dateAdded';

  Database? _db;

  DocumentDBWorker._();

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
              '$KEY_FILE_PATH TEXT,'
              '$KEY_DATE_ADDED INTEGER'
              ')',
        );
      },
    );
  }

  @override
  Future<int> create(Document document) async {
    try {
      Database db = await database;
      return await db.rawInsert(
        'INSERT INTO $TBL_NAME ($KEY_FILE_PATH, $KEY_DATE_ADDED) VALUES (?, ?)',
        [
          document.filePath,
          document.dateAdded?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        ],
      );
    } catch (e) {
      print('Error creating document: $e');
      return -1;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      Database db = await database;
      await db.delete(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  @override
  Future<Document?> get(int id) async {
    try {
      Database db = await database;
      var values = await db.query(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
      return values.isEmpty ? null : _documentFromMap(values.first);
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  @override
  Future<List<Document>> getAll() async {
    try {
      Database db = await database;
      var values = await db.query(TBL_NAME);
      print('Retrieved ${values.length} documents from database');
      return values.isNotEmpty
          ? values.map((m) => _documentFromMap(m)).toList()
          : [];
    } catch (e) {
      print('Error getting all documents: $e');
      return [];
    }
  }

  @override
  Future<void> update(Document document) async {
    try {
      Database db = await database;
      await db.update(
        TBL_NAME,
        _documentToMap(document),
        where: '$KEY_ID = ?',
        whereArgs: [document.id],
      );
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Document _documentFromMap(Map<String, dynamic> map) {
    return Document(
      id: map[KEY_ID],
      filePath: map[KEY_FILE_PATH],
      dateAdded: map[KEY_DATE_ADDED] != null
          ? DateTime.fromMillisecondsSinceEpoch(map[KEY_DATE_ADDED])
          : null,
    );
  }

  Map<String, dynamic> _documentToMap(Document document) => <String, dynamic>{
    KEY_ID: document.id,
    KEY_FILE_PATH: document.filePath,
    KEY_DATE_ADDED: document.dateAdded?.millisecondsSinceEpoch,
  };
}