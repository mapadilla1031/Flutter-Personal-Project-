//Marko Padilla Last modified on 04/24/25
import 'package:intl/intl.dart';
import '../base_model.dart';
import 'expenses_db_worker.dart';

ExpensesModel expensesModel = ExpensesModel();

class ExpensesModel extends BaseModel<Expense> {
  ExpensesModel() : super(ExpensesDBWorker.db);
}

class Expense extends Entry with DateMixin {String? title;double? amount;String? category;String? paymentMethod;
  static const List<String> categories = [
    'Food',
    'Gas',
    'Home',
    'Transportation',
    'Entertainment',
    'Utilities',
    'Shopping',
    'Health',
    'Travel',
    'Other'
  ];

  // list payment methods
  static const List<String> paymentMethods = ['Cash', 'Credit', 'Debit'];
  Expense({
    super.id = Entry.NO_ID,
    this.title,
    this.amount,
    this.category = 'Other',
    this.paymentMethod = 'Credit',
    DateTime? date,
  }) {
    this.date = date ?? DateTime.now();
  }

  // formatted string representation of the amount
  String get formattedAmount {
    if (amount == null) return '';
    final formatter = NumberFormat.currency(symbol: '\$');
    return formatter.format(amount);
  }

  // string of the Expense object
  @override
  String toString() => '{id=$id, title=$title, amount=$amount, '
      'category=$category, date=$date, paymentMethod=$paymentMethod}';
}