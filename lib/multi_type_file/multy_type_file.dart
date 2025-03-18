import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

class FileController extends GetxController {
  var selectedFiles = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  // Pick an image from Camera
  Future<void> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      selectedFiles.add(File(image.path));
    }
  }

  // Pick an image from Gallery
  Future<void> pickImageFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedFiles.add(File(image.path));
    }
  }

  // Pick files (PDF, DOCX, XLS, etc.)
  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
    );

    if (result != null) {
      for (var file in result.files) {
        if (file.path != null) {
          selectedFiles.add(File(file.path!));
        }
      }
    }
  }

  // Get the paths of selected files
  List<String> getSelectedFilePaths() {
    if (selectedFiles.isEmpty) {
      return [];
    }
    return selectedFiles.map((file) => file.path).toList();
  }

  void printSelectedFiles() {
    for (var file in selectedFiles) {
      print("File Name: ${file.path.split('/').last}");
      print("File Path: ${file.path}");
    }
  }

  // Remove file from list
  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }

  // Open a file
  void openFile(File file) {
    OpenFilex.open(file.path);
  }
}






class FileUploadScreen extends StatelessWidget {
  final FileController fileController = Get.put(FileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Upload Files")),
      body: Column(
        children: [
          // Buttons to pick images & files
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton.icon(
                onPressed: fileController.pickImageFromCamera,
                icon: Icon(Icons.camera),
                label: Text("Camera"),
              ),
              ElevatedButton.icon(
                onPressed: fileController.pickImageFromGallery,
                icon: Icon(Icons.image),
                label: Text("Gallery"),
              ),
              ElevatedButton.icon(
                onPressed: fileController.pickFile,
                icon: Icon(Icons.attach_file),
                label: Text("Files"),
              ),  ElevatedButton.icon(
                onPressed: fileController.printSelectedFiles ,
                icon: Icon(Icons.abc),
                label: Text("Files"),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Horizontal Scroll List for Selected Files
          Obx(() => fileController.selectedFiles.isEmpty
              ? Text("No files selected")
              : SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: fileController.selectedFiles.length,
              itemBuilder: (context, index) {
                File file = fileController.selectedFiles[index];
                String fileName = file.path.split('/').last;
                String fileExtension = fileName.split('.').last.toLowerCase();

                // Select icons based on file type
                Widget fileIcon;
                if (['jpg', 'jpeg', 'png'].contains(fileExtension)) {
                  fileIcon = Image.file(file, width: 80, height: 80, fit: BoxFit.cover);
                } else if (fileExtension == 'pdf') {
                  fileIcon = Icon(Icons.picture_as_pdf, size: 50, color: Colors.red);
                } else if (['doc', 'docx'].contains(fileExtension)) {
                  fileIcon = Icon(Icons.description, size: 50, color: Colors.blue);
                } else if (['xls', 'xlsx'].contains(fileExtension)) {
                  fileIcon = Icon(Icons.table_chart, size: 50, color: Colors.green);
                } else {
                  fileIcon = Icon(Icons.insert_drive_file, size: 50, color: Colors.grey);
                }

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => fileController.openFile(file), // Open file
                      child: Container(
                        width: 100,
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            fileIcon,
                            Text(
                              fileName,
                              style: TextStyle(fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -5,
                      right: -5,
                      child: GestureDetector(
                        onTap: () => fileController.removeFile(index),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )),
        ],
      ),
    );
  }
}
