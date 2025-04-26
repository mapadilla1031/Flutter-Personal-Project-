//Marko Padilla Last modified on 04/24/25
import 'package:flutterbook/base_model.dart';
import 'package:sqflite/sqflite.dart';
import 'expenses_model.dart';

//table names and and cols keys
class ExpensesDBWorker implements EntryDBWorker<Expense> {
  static final ExpensesDBWorker db = ExpensesDBWorker._();

  static const String DB_NAME = 'expenses.db';
  static const String TBL_NAME = 'expenses';
  static const String KEY_ID = 'id';
  static const String KEY_TITLE = 'title';
  static const String KEY_AMOUNT = 'amount';
  static const String KEY_CATEGORY = 'category';
  static const String KEY_DATE = 'date';
  static const String KEY_PAYMENT_METHOD = 'payment_method';

  Database? _db;

  ExpensesDBWorker._();//private constructor

  Future<Database> get database async => _db ??= await _init();

  //init db and create table
  Future<Database> _init() async {
    return await openDatabase(
      DB_NAME,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute(
          'CREATE TABLE IF NOT EXISTS $TBL_NAME ('
              '$KEY_ID INTEGER PRIMARY KEY,'
              '$KEY_TITLE TEXT,'
              '$KEY_AMOUNT REAL,'
              '$KEY_CATEGORY TEXT,'
              '$KEY_DATE INTEGER,'
              '$KEY_PAYMENT_METHOD TEXT'
              ')',
        );
      },
    );
  }
//insert new expense
  @override
  Future<int> create(Expense expense) async {
    Database db = await database;
    return await db.rawInsert(
      'INSERT INTO $TBL_NAME ($KEY_TITLE, $KEY_AMOUNT, $KEY_CATEGORY, $KEY_DATE, $KEY_PAYMENT_METHOD) '
          'VALUES (?, ?, ?, ?, ?)',
      [
        expense.title,
        expense.amount,
        expense.category,
        expense.dateInUnix ?? DateTime.now().millisecondsSinceEpoch,
        expense.paymentMethod,
      ],
    );
  }

  @override
  Future<void> delete(int id) async {
    Database db = await database;
    await db.delete(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
  }

  @override
  Future<Expense?> get(int id) async {
    Database db = await database;
    var values =
    await db.query(TBL_NAME, where: '$KEY_ID = ?', whereArgs: [id]);
    return values.isEmpty ? null : _expenseFromMap(values.first);
  }

  @override
  Future<List<Expense>> getAll() async {
    Database db = await database;
    var values = await db.query(TBL_NAME, orderBy: '$KEY_DATE DESC');
    return values.isNotEmpty
        ? values.map((m) => _expenseFromMap(m)).toList()
        : [];
  }
//use an already inserted expense
  @override
  Future<void> update(Expense expense) async {
    Database db = await database;
    await db.update(
      TBL_NAME,
      _expenseToMap(expense),
      where: '$KEY_ID = ?',
      whereArgs: [expense.id],
    );
  }
//map data to expense object
  Expense _expenseFromMap(Map<String, dynamic> map) => Expense(
    id: map[KEY_ID],
    title: map[KEY_TITLE],
    amount: map[KEY_AMOUNT],
    category: map[KEY_CATEGORY],
    paymentMethod: map[KEY_PAYMENT_METHOD],
  )..dateInUnix = map[KEY_DATE];

//data insertion expense object to map
  Map<String, dynamic> _expenseToMap(Expense expense) => <String, dynamic>{
    KEY_ID: expense.id,
    KEY_TITLE: expense.title,
    KEY_AMOUNT: expense.amount,
    KEY_CATEGORY: expense.category,
    KEY_DATE: expense.dateInUnix,
    KEY_PAYMENT_METHOD: expense.paymentMethod,
  };
}