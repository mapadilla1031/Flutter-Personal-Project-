//Marko Padilla Last modified on 04/24/25
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';


abstract class BaseModel<T extends Entry> extends Model {
  static const int STACK_INDEX_LIST_VIEW = 0;
  static const int STACK_INDEX_EDIT_VIEW = 1;
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
  Future<int?> stopEditingEntry({bool save = false}) async {
    int? id;
    if (save) {
      var item = entryBeingEdited!;
      if (item.isNew) {
        id = await database.create(item);
      } else {
        await database.update(item);
        id = item.id;
      }
    }
    loadData();
    entryBeingEdited = null;
    stackIndex = BaseModel.STACK_INDEX_LIST_VIEW;
    return id;
  }
  Future<void> deleteEntry(T entry) async {
    await database.delete(entry.id);
    loadData();
  }

  void loadData() async {
    entryList.clear();
    entryList.addAll(await database.getAll());
    notifyListeners();
  }
}

abstract class Entry {

  static const NO_ID = -1;

  int id;

  Entry({this.id = NO_ID});

  bool get isNew => id == NO_ID;
}

abstract interface class EntryDBWorker<T extends Entry> {
  Future<int> create(T note);
  Future<void> update(T note);
  Future<void> delete(int id);
  Future<T?> get(int id);
  Future<List<T>> getAll();
}

mixin DateMixin {
  DateTime? date;

  bool get hasDate => date != null;


  int? get dateInUnix => hasDate ? date!.millisecondsSinceEpoch : null;


  set dateInUnix(int? millis) {
    if (millis != null) {
      date = DateTime.fromMillisecondsSinceEpoch(millis);
    }
  }

  String? get formattedDate => hasDate ? formatDate(date!) : null;

  static String formatDate(DateTime date) {
    return DateFormat.yMMMMd('en_US').format(date.toLocal());
  }
}

