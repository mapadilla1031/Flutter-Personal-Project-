//Marko Padilla Last modified on 04/24/25
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'expenses_entry_view.dart';
import 'expenses_list_view.dart';
import 'expenses_model.dart';

//manage the switch from list to entry view
class Expenses extends StatelessWidget {
  Expenses({Key? key}) : super(key: key) {
    expensesModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<ExpensesModel>(
      model: expensesModel,
      child: ScopedModelDescendant<ExpensesModel>(
        builder: (BuildContext context, Widget? child, ExpensesModel model) {
          return IndexedStack(
            index: model.stackIndex,
            children: <Widget>[
              ExpensesListView(),
              ExpensesEntryView(),
            ],
          );
        },
      ),
    );
  }
}