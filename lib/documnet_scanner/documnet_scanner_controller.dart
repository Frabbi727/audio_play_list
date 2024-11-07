import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class DocumentScannerController extends GetxController{
  final textRecognizer = TextRecognizer();
  var recognizedText = ''.obs;
  var isLoading = false.obs;
  RxString nidFrontImagePath = "".obs;
  RxString nidFrontImageName = "".obs;
  Rx<File> nidFrontImageFile = Rx<File>(File(''));

  RxString nidBackImagePath = "".obs;
  RxString nidBackImageName = "".obs;
  Rx<File> nidBackImageFile = Rx<File>(File(''));

  var extractedName = ''.obs;
  var extractedDateOfBirth = ''.obs;
  var extractedIdNo = ''.obs;
  RxBool imageIsNotClear = false.obs;
  DocumentScanner? documentScanner;
  DocumentScanningResult? result;



  // Future startScan() async {
  //   try {
  //     _result = null;
  //
  //     _documentScanner = DocumentScanner(
  //       options: DocumentScannerOptions(
  //         documentFormat:DocumentFormat.jpeg ,
  //         mode: ScannerMode.full,
  //         isGalleryImport: false,
  //         pageLimit: 1,
  //       ),
  //     );
  //     _result = await _documentScanner?.scanDocument();
  //     print('result: ${_result?.images.first}');
  //     await processImage(_result!.images.first);
  //
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }
  Future getNidFrontImageFromCamera() async {
    fontImageDataAndOcrClear(); // Clear previous data

    try {
      final DocumentScanner documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.full,
          isGalleryImport: false,
          pageLimit: 1,
        ),
      );

      result = await documentScanner.scanDocument();

      if (result != null && result!.images.isNotEmpty) {

        final scannedImagePath = result!.images.first;
        nidFrontImagePath.value = scannedImagePath;
        nidFrontImageName.value = scannedImagePath.split('/').last; // Extracts the image name

        Get.back();

        bool processingResult = await processImage(scannedImagePath);
        if (processingResult) {
          imageIsNotClear.value = false;
          Get.snackbar(
            "Nice photo",
            "Take the backside of NID",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          imageIsNotClear.value = true;
          fontImageDataAndOcrClear();
          Get.snackbar(
            "Warning",
            "Image is not clear or data is incomplete. Please capture the photo again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("No document scanned.");
      }

    //  documentScanner.close(); // Close the scanner after use

    } catch (e) {
      debugPrint("Error during document scanning: $e");
      Get.snackbar(
        "Error",
        "An error occurred while scanning. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }


/*  Future getNidFrontImageFromCamera() async {
    fontImageDataAndOcrClear();
    final ImagePicker picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.camera);
    try {
      if (image != null) {
        nidFrontImagePath.value = image.path;
        nidFrontImageName.value = image.name;
        Get.back();

        bool result = await processImage(image);
        if (result) {
          imageIsNotClear.value = false;
          Get.snackbar(
            "Nice photo",
            "Take backside of nid",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        } else {
          imageIsNotClear.value = true;
          image = null;
          fontImageDataAndOcrClear();
          Get.snackbar(
            "Warning",
            "Image is not clear or data is incomplete. Please capture the photo again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint("No image picked");
      }
    } catch (e) {
      debugPrint("Image from camera exception $e");
    }
  }*/

  Future getNidFrontImageFromGallery() async {
    fontImageDataAndOcrClear();
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    try {
      if (image != null) {
        nidFrontImagePath.value = image.path;
        nidFrontImageName.value = image.name;
        Get.back();
        //  await processImage(image);
      } else {
        print("No image picked");
      }
    } catch (e) {
      debugPrint("Image from gallery exception $e");
    }
  }

  Future getNidBackImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    try {
      if (image != null) {
        nidBackImagePath.value = image.path;
        nidBackImageName.value = image.name;
        Get.back();
      } else {
        print("No image picked");
      }
    } catch (e) {
      debugPrint("Image from camera exception $e");
    }
  }

  Future getNidBackImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    try {
      if (image != null) {
        nidBackImagePath.value = image.path;
        nidBackImageName.value = image.name;
        Get.back();
      } else {
        print("No image picked");
      }
    } catch (e) {
      debugPrint("Image from gallery exception $e");
    }
  }

  Future<bool> processImage(String image) async {
    debugPrint("Processing image");
    debugPrint("Camera Image path ${image}");
    isLoading.value = true;

    final inputImage = InputImage.fromFilePath(image);
    debugPrint("TAG 1: ${inputImage.filePath}");

    try {
      final RecognizedText recognizedTextResult =
      await textRecognizer.processImage(inputImage);
      debugPrint("TAG 2: ${recognizedTextResult.text}");
      recognizedText.value = recognizedTextResult.text;

      debugPrint("OCR value: ${recognizedText.value}");

      // Extract fields using regular expressions
      final nameMatch =
      RegExp(r'Name:\s*(.*)').firstMatch(recognizedText.value);
      extractedName.value = nameMatch?.group(1)?.trim() ?? '';

      final dobMatch = RegExp(r'Date of Birth:\s*(\d{2} \w+ \d{4})')
          .firstMatch(recognizedText.value);
      extractedDateOfBirth.value = dobMatch?.group(1)?.trim() ?? '';

      final idMatch =
      RegExp(r'ID NO:\s*(\d+)').firstMatch(recognizedText.value);
      extractedIdNo.value = idMatch?.group(1)?.trim() ?? '';

      debugPrint("Extracted Name: ${extractedName.value}");
      debugPrint("Extracted Date of Birth: ${extractedDateOfBirth.value}");
      debugPrint("Extracted ID NO: ${extractedIdNo.value}");

      if (extractedName.value.isEmpty ||
          extractedDateOfBirth.value.isEmpty ||
          extractedIdNo.value.isEmpty) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint("Error during OCR: $e");
      recognizedText.value = "Error during OCR: ${e.toString()}";
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void fontImageDataAndOcrClear() {
    debugPrint("Clear method called");
    nidBackImagePath.value = "";
    nidFrontImageName.value = "";
    extractedName.value = "";
    extractedDateOfBirth.value = '';
    extractedIdNo.value = '';
  }

  @override
  void onClose() {
    textRecognizer.close();
    super.onClose();
  }
}