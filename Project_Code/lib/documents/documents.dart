//Marko Padilla Last modified on 05/06/25
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../services/documents_service.dart';
import 'package:scoped_model/scoped_model.dart';
import 'documents_model.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Documents extends StatefulWidget {
  @override
  _DocumentsState createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  @override
  void initState() {
    super.initState();
    // Load documents from  the db
    documentsModel.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<DocumentsModel>(
      model: documentsModel,
      child: ScopedModelDescendant<DocumentsModel>(
        builder: (context, child, model) {
          return Scaffold(
            body: Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Travel Documents',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ],
                  ),
                ),

                // Documents grid or empty state
                Expanded(
                  child: model.entryList.isEmpty
                      ? _buildEmptyState()
                      : _buildDocumentsGrid(model),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddOptions(model),
              child: Icon(Icons.add),
              tooltip: 'Add Document',
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Empty',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8),
          Text(
            'Tap + to add document',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsGrid(DocumentsModel model) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: model.entryList.length,
      itemBuilder: (context, index) {
        return _buildSlidableDocumentCard(model.entryList[index], model);
      },
    );
  }

  Widget _buildSlidableDocumentCard(Document document, DocumentsModel model) {
    if (document.filePath == null) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text('Invalid document')),
      );
    }

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              _confirmDelete(document, model);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _viewDocument(document.filePath!),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FutureBuilder<bool>(
              future: DocumentService.fileExists(document.filePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                bool fileExists = snapshot.data ?? false;

                if (!fileExists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('File not found',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // If file exists check if its an image or PDF
                String extension = path.extension(document.filePath!).toLowerCase();
                bool isImage = ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
                bool isPDF = extension == '.pdf';

                if (isImage) {
                  return Image.file(
                    File(document.filePath!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $error');
                      return _buildFileTypeIcon(extension);
                    },
                  );
                } else if (isPDF) {
                  return _buildFileTypeIcon('.pdf');
                } else {
                  return _buildFileTypeIcon(extension);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileTypeIcon(String extension) {
    IconData iconData;
    Color iconColor;
    String label;

    // icon based on pdf or else image icon
    if (extension.contains('.pdf')) {
      iconData = Icons.picture_as_pdf;
      iconColor = Colors.red;
      label = 'PDF';
    } else {
      iconData = Icons.image;
      iconColor = Colors.green;
      label = 'IMAGE';
    }

    return Container(
      color: Colors.grey[200],
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              iconData,
              size: 48,
              color: iconColor,
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOptions(DocumentsModel model) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(context);
                  _addPhotoDocument(model);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _addGalleryDocument(model);
                },
              ),
              // PDF option added
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Add PDF file'),
                onTap: () {
                  Navigator.pop(context);
                  _addPDFDocument(model);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addPhotoDocument(DocumentsModel model) async {
    try {
      final String? imagePath = await DocumentService.takePhoto();
      if (imagePath != null) {
        Document newDocument = Document(
          filePath: imagePath,
          dateAdded: DateTime.now(),
        );

        await model.database.create(newDocument);
        model.loadData(); // Reload the data to show the new document

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding photo document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addGalleryDocument(DocumentsModel model) async {
    try {
      final String? imagePath = await DocumentService.pickImage();
      if (imagePath != null) {
        Document newDocument = Document(
          filePath: imagePath,
          dateAdded: DateTime.now(),
        );

        await model.database.create(newDocument);
        model.loadData(); // Reload the data to show the new document

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding gallery document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding document'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _addPDFDocument(DocumentsModel model) async {
    try {
      final String? filePath = await DocumentService.pickPDF();
      if (filePath != null) {
        Document newDocument = Document(
          filePath: filePath,
          dateAdded: DateTime.now(),
        );

        await model.database.create(newDocument);
        model.loadData(); // Reload the data to show the new document

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF added'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error adding PDF document: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding PDF'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // method to handle PDF viewing
  void _viewDocument(String filePath) {
    // Check if file exists before trying to view it
    DocumentService.fileExists(filePath).then((exists) {
      if (!exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document file not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String extension = path.extension(filePath).toLowerCase();
      bool isImage = ['.jpg', '.jpeg', '.png', '.gif'].contains(extension);
      bool isPDF = extension == '.pdf';

      if (isImage) {
        // full screen image
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('Document'),
                backgroundColor: Colors.black,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(
                    File(filePath),
                    errorBuilder: (context, error, stackTrace) {
                      print('Error viewing image: $error');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image,
                              size: 64,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Image could not be loaded',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (isPDF) {
        // New PDF viewer implementation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text('PDF Document'),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: PDFView(
                filePath: filePath,
                enableSwipe: true,
                swipeHorizontal: true,
                autoSpacing: false,
                pageFling: true,
                pageSnap: true,
                defaultPage: 0,
                fitPolicy: FitPolicy.BOTH,
                preventLinkNavigation: false,
                onRender: (_pages) {
                  print('PDF rendered with $_pages pages');
                },
                onError: (error) {
                  print('Error with the PDF $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error opening the PDF'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
                onPageError: (page, error) {
                  print('Error $page: $error');
                },
              ),
            ),
          ),
        );
      } else {
        // For other file types
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('file type not allowed'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _confirmDelete(Document document, DocumentsModel model) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Document'),
          content: Text('Are you sure you want to delete this document?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();

                try {
                  // Delete the file from storage
                  if (document.filePath != null) {
                    await DocumentService.deleteDocument(document.filePath!);
                  }
                  // Delete from the database
                  await model.deleteEntry(document);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Document deleted'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  print('Error deleting document: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting document'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}