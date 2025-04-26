//Marko Padilla Last modified on 04/24/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'expenses_model.dart';

class ExpensesListView extends StatelessWidget {
  const ExpensesListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ExpensesModel>(
      model: expensesModel,
      child: ScopedModelDescendant<ExpensesModel>(
        builder: (BuildContext context, Widget? child, ExpensesModel model) {
          // Calc total amount
          double totalAmount = 0;
          for (var expense in model.entryList) {
            if (expense.amount != null) {
              totalAmount += expense.amount!;
            }
          }

          // by category
          final Map<String, List<Expense>> expensesByCategory = {};
          for (var expense in model.entryList) {
            if (expense.category != null) {
              expensesByCategory[expense.category!] =
                  expensesByCategory[expense.category!] ?? [];
              expensesByCategory[expense.category!]!.add(expense);
            }
          }

          // Calc totals
          final Map<String, double> categoryTotals = {};
          for (var entry in expensesByCategory.entries) {
            double total = 0;
            for (var expense in entry.value) {
              if (expense.amount != null) {
                total += expense.amount!;
              }
            }
            categoryTotals[entry.key] = total;
          }

          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => model.startEditingEntry(Expense()),
            ),
            body: Column(
              children: [
                // Total amount
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Category grid
                Expanded(
                  child: model.entryList.isEmpty
                      ? const Center(
                    child: Text('Press + to add new Expense'),
                  )
                      : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: expensesByCategory.length,
                    itemBuilder: (context, index) {
                      final category = expensesByCategory.keys.elementAt(index);
                      final categoryTotal = categoryTotals[category] ?? 0.0;
                      final expenses = expensesByCategory[category] ?? [];
                      return _buildCategoryCard(context, category, categoryTotal, expenses, model);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, double amount,
      List<Expense> expenses, ExpensesModel model) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      color: Colors.blue,
      child: InkWell(
        onTap: () {
          _showExpenses(context, category, expenses, model);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getCategoryIcon(category),
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Gas':
        return Icons.local_gas_station;
      case 'Home Improvement':
        return Icons.home;
      case 'Transportation':
        return Icons.directions_car;
      case 'Entertainment':
        return Icons.movie;
      case 'Utilities':
        return Icons.power;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Health':
        return Icons.local_hospital;
      case 'Travel':
        return Icons.flight;
      default:
        return Icons.loop;
    }
  }

  void _showExpenses(BuildContext context, String category,
      List<Expense> expenses, ExpensesModel model) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('$category Expenses'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return Slidable(
                  endActionPane: ActionPane(
                    extentRatio: 0.25,
                    motion: const ScrollMotion(),
                    children: <Widget>[
                      SlidableAction(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        label: 'Delete',
                        icon: Icons.delete,
                        onPressed: (ctx) {
                          Navigator.pop(dialogContext);
                          _deleteExpense(context, expense, model);
                        },
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(expense.title ?? 'No title'),
                    subtitle: Text(expense.formattedDate ?? ''),
                    trailing: Text(
                      expense.formattedAmount,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      model.startEditingEntry(expense);
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(BuildContext context, Expense expense, ExpensesModel model) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: Text('Delete ${expense.title}?'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Delete'),
              onPressed: () async {
                await model.deleteEntry(expense);
                Navigator.of(alertContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expense deleted'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}