import 'package:intl/intl.dart';
import '../base_model.dart';
import 'tasks_db_worker.dart';

TasksModel tasksModel = TasksModel();

class TasksModel extends BaseModel<Task> {
  TasksModel() : super(TasksDBWorker.db);

  Future<void> updateEntry(Task task) async {
    await database.update(task);
    loadData();
  }
}

class Task extends Entry with DateMixin {
  String? description;
  bool completed = false;

  Task({
    int id = Entry.NO_ID,
    this.description,
    DateTime? dueDate,
    this.completed = false,
  }) : super(id: id) {
    date = dueDate;
  }
  bool get hasDueDate => hasDate;
  DateTime? get dueDate => date;
  set dueDate(DateTime? d) => date = d;
  int? get dueDateInUnix => dateInUnix;
  set dueDateInUnix(int? millis) => dateInUnix = millis;
  String? get formattedDueDate => formattedDate;

  @override
  String toString() => '{id=$id, description=$description, '
      'dueDate=$dueDate, completed=$completed }';
}