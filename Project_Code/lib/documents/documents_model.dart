//Marko Padilla Last modified on 05/06/25
import 'package:flutter/material.dart';
import '../base_model.dart';
import 'document_db_worker.dart';

class Document extends Entry {
  String? filePath;
  DateTime? dateAdded;

  Document({
    super.id = Entry.NO_ID,
    this.filePath,
    this.dateAdded,
  });
}

class DocumentsModel extends BaseModel<Document> {
  DocumentsModel() : super(DocumentDBWorker.db);
}

final documentsModel = DocumentsModel();