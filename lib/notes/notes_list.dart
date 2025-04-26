

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'notes_model.dart';

class NotesList extends StatelessWidget {
  const NotesList({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget? child, NotesModel model) {
          return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add, color: Colors.white),
                onPressed: () => model.startEditingEntry(Note()),
              ),
              body: ListView.builder(
                  itemCount: model.entryList.length,
                  itemBuilder: (BuildContext context, int index) {
                    Note note = model.entryList[index];
                    return Container(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Slidable(
                            endActionPane: ActionPane(
                              extentRatio: .25,
                              motion: const ScrollMotion(),
                              children: <Widget>[
                                SlidableAction(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  label: "Delete",
                                  icon: Icons.delete,
                                  onPressed: (ctx) =>
                                      _deleteNote(context, model, note),
                                )
                              ],
                            ),

                            child: Card(
                                elevation: 8,
                                color: note.color,
                                child: ListTile(
                                  title: Text(note.title ?? ''),
                                  subtitle: Text(note.content ?? ''),
                                  onTap: () => model.startEditingEntry(note),
                                )
                            )
                        )
                    );
                  }
              )
          );
        }
    );
  }

  _deleteNote(BuildContext context, NotesModel model, Note note) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext alertContext) {
          return AlertDialog(
              title: Text('Delete Note'),
              content: Text(
                  'Are you sure you want to delete ${note.title}?'
              ),
              actions: [
                ElevatedButton(child: Text('Cancel'),
                    onPressed: () => Navigator.of(alertContext).pop()
                ),
                ElevatedButton(child: Text('Delete'),
                    onPressed: () async {
                      await model.deleteEntry(note);
                      Navigator.of(alertContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              backgroundColor: Colors.red,
                              duration: Duration(seconds : 2),
                              content: Text('Note deleted')
                          )
                      );
                    }
                )
              ]
          );
        }
    );
  }
}

