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
  var extractedBlood = ''.obs;
  RxBool imageIsNotClear = false.obs;
  DocumentScanner? documentScanner;
  DocumentScanningResult? result;



  Future getNidFrontImageFromCamera() async {
    fontImageDataAndOcrClear(); // Clear previous data

    try {
      final DocumentScanner documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.full,
          isGalleryImport: true,
          pageLimit: 1,

        ),
      );

      result = await documentScanner.scanDocument();

      if (result != null && result!.images.isNotEmpty) {

        nidFrontImagePath.value = result!.images.first;
        nidFrontImageName.value = nidFrontImagePath.value.split('/').last;
     /*   bool fileExists = await File(nidFrontImagePath.value).exists();
        if (fileExists) {
          File imageFile =File(nidFrontImagePath.value);
          print("Image file exists at path: ${nidFrontImagePath.value}");
          print("Image file exists at : ${imageFile}");
        } else {
          print("Image file not found at path: ${nidFrontImagePath.value}");
        }*/



        bool processingResult = await processImageForFrontNid(File(nidFrontImagePath.value));
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

      documentScanner.close();

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




  Future getNidBackImageFromCamera() async {

    try {
      final DocumentScanner documentScanner = DocumentScanner(
        options: DocumentScannerOptions(
          documentFormat: DocumentFormat.jpeg,
          mode: ScannerMode.full,
          isGalleryImport: true,
          pageLimit: 1,

        ),
      );

      result = await documentScanner.scanDocument();

      if (result != null && result!.images.isNotEmpty) {

        nidBackImagePath.value = result!.images.first;
        nidBackImageName.value = nidBackImagePath.value.split('/').last;
        bool fileExists = await File(nidBackImagePath.value).exists();
        if (fileExists) {
          File imageFile = File(nidBackImagePath.value);
          print("Image file exists at path: ${nidBackImagePath.value}");
          print("Image file exists at : ${imageFile}");
        } else {
          print("Image file not found at path: ${nidBackImagePath.value}");
        }
      /*  bool processingResult = await processImageForBackNid(File(nidBackImagePath.value));

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
        };*/


      } else {
        debugPrint("No document scanned.");
      }

      documentScanner.close();
    } catch (e) {
      debugPrint("Image from camera exception $e");
    }
  }



  Future<bool> processImageForFrontNid(File image) async {
    debugPrint("Processing image");
    debugPrint("Camera Image path $image");
    isLoading.value = true;

    final inputImage = InputImage.fromFilePath(image.path);
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

  Future<bool> processImageForBackNid(File image) async {
    debugPrint("Processing image");
    debugPrint("Camera Image path $image");
    isLoading.value = true;

    final inputImage = InputImage.fromFilePath(image.path);
    debugPrint("TAG 1: ${inputImage.filePath}");

    try {
      final RecognizedText recognizedTextResult =
      await textRecognizer.processImage(inputImage);
      debugPrint("TAG 2: ${recognizedTextResult.text}");
      recognizedText.value = recognizedTextResult.text;

      debugPrint("OCR value: ${recognizedText.value}");

      // Extract fields using regular expressions
      final extracted =
      RegExp(r'Blood Group:\s*(.*)').firstMatch(recognizedText.value);
      extractedBlood.value = extracted?.group(1)?.trim() ?? '';


      debugPrint("Extracted Name: ${extractedBlood.value}");


      if (extractedBlood.value.isEmpty) {
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
    result?.images.clear();
    nidFrontImagePath.value = "";
    nidFrontImageName.value = "";
    extractedName.value = "";
    extractedDateOfBirth.value = '';
    extractedIdNo.value = '';
  }

  @override
  void onClose() {
    textRecognizer.close();
    fontImageDataAndOcrClear();
    documentScanner?.close();
    super.onClose();
  }
}