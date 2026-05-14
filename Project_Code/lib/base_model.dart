//Marko Padilla Last modified on 05/06/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

abstract class EntryDBWorker<T extends Entry> {
  Future<int> create(T entry);
  Future<void> update(T entry);
  Future<T?> get(int id);
  Future<List<T>> getAll();
  Future<void> delete(int id);
}

abstract class Entry {
  static const int NO_ID = -1;

  int id;

  Entry({this.id = NO_ID});

  bool get isNew => id == NO_ID;
}

class BaseModel<T extends Entry> extends Model {
  static const int STACK_INDEX_LIST_VIEW = 0;
  static const int STACK_INDEX_EDIT_VIEW = 1;
  static const int STACK_INDEX_DETAIL_VIEW = 2;

  int _stackIndex = STACK_INDEX_LIST_VIEW;

  final EntryDBWorker<T> database;

  final List<T> entryList = [];

  T? entryBeingEdited;

  BaseModel(this.database);

  int get stackIndex => _stackIndex;

  set stackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }

  void refreshUI() {
    notifyListeners();
  }

  void startEditingEntry(T entry) {
    entryBeingEdited = entry;
    stackIndex = BaseModel.STACK_INDEX_EDIT_VIEW;
  }

  void viewEntryDetails(T entry) {
    entryBeingEdited = entry;
    stackIndex = BaseModel.STACK_INDEX_DETAIL_VIEW;
  }

  Future<int?> stopEditingEntry({bool save = false}) async {
    int? id;
    if (save) {
      try {
        var item = entryBeingEdited!;
        if (item.isNew) {
          id = await database.create(item);
          if (id == -1) {
            // Create failed
            print('Failed to create new entry');
            return null;
          }
        } else {
          await database.update(item);
          id = item.id;
        }
      } catch (e) {
        print('Error in stopEditingEntry: $e');
        return null;
      }
    }
    await loadData();
    entryBeingEdited = null;
    stackIndex = BaseModel.STACK_INDEX_LIST_VIEW;
    return id;
  }

  Future<void> deleteEntry(T entry) async {
    await database.delete(entry.id);
    entryList.clear();    //need to clear list before reloading to prevent duplicates
    await loadData();
  }

  Future<void> loadData() async {
    entryList.clear();
    List<T> entries = await database.getAll();
    // print('Loaded ${entries.length} entries from database');
    entryList.addAll(entries);
    notifyListeners();
  }
}