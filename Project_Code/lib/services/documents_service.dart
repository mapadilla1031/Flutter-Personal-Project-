//Marko Padilla Last modified on 05/06/25
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

class DocumentService {
  static final ImagePicker _picker = ImagePicker();

  //documents directory path
  static Future<String> getDocumentsPath() async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String documentsPath = path.join(appDocDir.path, 'triptap_documents');

    // Create the directory if not there
    final dir = Directory(documentsPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    return documentsPath;
  }

  static Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) {
        return null;
      }

      return await _saveImage(File(image.path));
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  static Future<String?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return null;
      }

      return await _saveImage(File(image.path));
    } catch (e) {
      print('Error $e');
      return null;
    }
  }

  //  PDF
  static Future<String?> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],);
      if (result == null || result.files.isEmpty) {
        return null;
      }
      PlatformFile file = result.files.first;
      if (file.path != null) {
        // Save file to app directory
        return await _saveFile(File(file.path!), 'pdf');
      }

      return null;
    } catch (e) {
      print('Error picking PDF: $e');
      return null;
    }
  }

  // save a file to app documents directory
  static Future<String> _saveFile(File file, String extension) async {
    final String documentsPath = await getDocumentsPath();

    final String fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.$extension';
    final String filePath = path.join(documentsPath, fileName);

    // file to documents directory
    try {
      final File newFile = await file.copy(filePath);
      print('File saved to: ${newFile.path}');
      return newFile.path;
    } catch (e) {
      print('Error saving file: $e');
      throw e;
    }
  }

  //save an image to the app's documents directory
  static Future<String> _saveImage(File imageFile) async {
    String extension = path.extension(imageFile.path);
    if (extension.isNotEmpty) {
      extension = extension.startsWith('.') ? extension.substring(1) : extension;
    } else {
      extension = 'jpg';
    }

    return await _saveFile(imageFile, extension);
  }

  static Future<bool> fileExists(String? filePath) async {
    if (filePath == null || filePath.isEmpty) return false;

    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      print('Error checking if file exists: $e');
      return false;
    }
  }

  // Delete doc
  static Future<void> deleteDocument(String filePath) async {
    try {
      if (await fileExists(filePath)) {
        final file = File(filePath);
        await file.delete();
        print('File deleted: $filePath');
      } else {
        print('File not found for deletion: $filePath');
      }
    } catch (e) {
      print('Error deleting document: $e');
    }
  }
}