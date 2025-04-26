

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notes_model.dart';

class NotesEntry extends StatelessWidget {

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry({super.key}) {
    _titleEditingController.addListener(() {
      notesModel.entryBeingEdited!.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entryBeingEdited!.content = _contentEditingController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<NotesModel>(
        builder: (BuildContext context, Widget? child, NotesModel model) {

          // for "editing" an existing note
          _titleEditingController.text =
              model.entryBeingEdited?.title ?? '';
          _contentEditingController.text =
              model.entryBeingEdited?.content ?? '';

          return Scaffold(
              bottomNavigationBar: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildControlButtons(context, model)),
              body: Form(
                  key: _formKey,
                  child: ListView(
                      children: [
                        _buildTitleListTile(),
                        _buildContentListTile(),
                        _buildColorListTile(context, model)
                      ]
                  )
              )
          );
        }
    );
  }

  ListTile _buildTitleListTile() {
    return ListTile(
        leading: Icon(Icons.title),
        title: TextFormField(
          decoration: InputDecoration(hintText: 'Title'),
          controller: _titleEditingController,
          validator: (String? value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a title';
            }
            return null;
          },
        )
    );
  }

  ListTile _buildContentListTile() {
    return ListTile(
        leading: Icon(Icons.content_paste),
        title: TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: 8,
            decoration: const InputDecoration(hintText: 'Content'),
            controller: _contentEditingController,
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return 'Please enter content';
              }
              return null;
            }
        )
    );
  }

  ListTile _buildColorListTile(BuildContext context, NotesModel model) {
    return ListTile(
        leading: Icon(Icons.color_lens),
        title: Row(
            children: Note.allColors.expand((color) =>
            [_buildColorBox(context, color, model),
              Spacer()]).toList()..removeLast()
        )
    );
  }

  GestureDetector _buildColorBox(BuildContext context, Color color, NotesModel model) {
    return GestureDetector(
      child: Container(
          decoration: ShapeDecoration(
              shape: Border.all(width: 16, color: color) +
                  Border.all(width: 4, color: model.color == color ?
                  color: Theme.of(context).canvasColor
                  )
          )
      ),
      onTap: () => model.color = color,
    );
  }

  Row _buildControlButtons(BuildContext context, NotesModel model) {
    return Row(children: [
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
        onPressed: () {
          _save(context, notesModel);
        },
      )
    ]
    );
  }

  void _save(BuildContext context, NotesModel model) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    model.stopEditingEntry(save: true);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2), content: Text('Note saved'),
        )
    );
  }
}

