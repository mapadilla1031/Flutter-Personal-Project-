import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'tasks_model.dart';

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController =
  TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({Key? key}) : super(key: key) {
    _descriptionEditingController.addListener(() {
      if (tasksModel.entryBeingEdited != null) {
        tasksModel.entryBeingEdited!.description =
            _descriptionEditingController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext context, Widget? child, TasksModel model) {
          // For editing an existing task, set the current description.
          _descriptionEditingController.text =
              model.entryBeingEdited?.description ?? '';

          return Scaffold(
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ElevatedButton(
                    child: Text('Cancel'),
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
                  ListTile(
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                      controller: _descriptionEditingController,
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(hintText: 'Description'),
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.today),
                    title: const Text('Due Date'),
                    subtitle: _dueDate(model.entryBeingEdited),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async => _editDueDate(context, model),
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

  Text? _dueDate(Task? task) {
    final date = task?.formattedDueDate;
    return date != null ? Text(date) : null;
  }
  Future<void> _editDueDate(BuildContext context, TasksModel model) async {
    DateTime? chosenDate =
    await _selectDate(context, model.entryBeingEdited!.dueDate);
    if (chosenDate != null) {
      model.entryBeingEdited!.dueDate = chosenDate;
      model.refreshUI();
    }
  }
  void _save(BuildContext context, TasksModel model) {
    if (!_formKey.currentState!.validate()) return;
    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task saved'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
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
}