//Marko Padilla Last modified on 04/24/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:intl/intl.dart';
import 'expenses_model.dart';

//adding and del expense data entry view
class ExpensesEntryView extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _amountEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ExpensesEntryView({Key? key}) : super(key: key) {
    _titleEditingController.addListener(() {
      if (expensesModel.entryBeingEdited != null) {
        expensesModel.entryBeingEdited!.title = _titleEditingController.text;
      }
    });

    _amountEditingController.addListener(() {
      if (expensesModel.entryBeingEdited != null) {
        final text = _amountEditingController.text;
        expensesModel.entryBeingEdited!.amount =
        text.isNotEmpty ? double.tryParse(text) : null;
      }
    });
  }

  //ui entering and edit expenses build method
  @override
  Widget build(BuildContext context) {
    return ScopedModel<ExpensesModel>(
      model: expensesModel,
      child: ScopedModelDescendant<ExpensesModel>(
        builder: (BuildContext context, Widget? child, ExpensesModel model) {
          // editing an existing expense, set the values
          _titleEditingController.text = model.entryBeingEdited?.title ?? '';
          _amountEditingController.text = model.entryBeingEdited?.amount?.toString() ?? '';

          // Get the current category or default
          String currentCategory = model.entryBeingEdited?.category ?? Expense.categories.first;
          String currentPaymentMethod = model.entryBeingEdited?.paymentMethod ?? Expense.paymentMethods.first;

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      model.stopEditingEntry();
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () => _save(context, model),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  // Title field
                  ListTile(
                    leading: const Icon(Icons.title),
                    title: TextFormField(
                      controller: _titleEditingController,
                      decoration: const InputDecoration(hintText: 'Title'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Amount field
                  ListTile(
                    leading: const Icon(Icons.attach_money),
                    title: TextFormField(
                      controller: _amountEditingController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Amount'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),

                  // Category dropdown
                  ListTile(
                    leading: const Icon(Icons.loop),
                    title: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category'),
                      value: currentCategory,
                      items: Expense.categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null && model.entryBeingEdited != null) {
                          model.entryBeingEdited!.category = newValue;
                        }
                      },
                    ),
                  ),

                  // Payment Method dropdown
                  ListTile(
                    leading: const Icon(Icons.payment),
                    title: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Payment Method'),
                      value: currentPaymentMethod,
                      items: Expense.paymentMethods.map((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null && model.entryBeingEdited != null) {
                          model.entryBeingEdited!.paymentMethod = newValue;
                        }
                      },
                    ),
                  ),

                  // Date picker
                  ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Date'),
                    subtitle: Text(model.entryBeingEdited?.formattedDate ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async => _editDate(context, model),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _editDate(BuildContext context, ExpensesModel model) async {
    DateTime? chosenDate = await _selectDate(context, model.entryBeingEdited!.date);
    if (chosenDate != null) {
      model.entryBeingEdited!.date = chosenDate;
      model.refreshUI();
    }
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? date) async {
    DateTime initialDate = date ?? DateTime.now();
    return await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  void _save(BuildContext context, ExpensesModel model) {
    if (!_formKey.currentState!.validate()) return;

    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense saved'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}