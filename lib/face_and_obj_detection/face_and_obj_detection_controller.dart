import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:path_provider/path_provider.dart';

class FaceAndObjDetectionController  extends GetxController{
  late CameraController cameraController;
  var isInitialized = false.obs;
  var faceDetected = false.obs;
  var objectDetected = false.obs;
  var boundingBoxes = <Rect>[].obs;
  var isDetecting = false;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await cameraController.initialize();
    isInitialized.value = true;
    cameraController.startImageStream((image) {
      if (!isDetecting) {
        isDetecting = true;
        _processCameraImage(image);
      }
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final faceDetector = FaceDetector(options: FaceDetectorOptions());
    final objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(classifyObjects: true, mode: DetectionMode.single, multipleObjects: false),
    );

    final inputImage = _convertCameraImage(image);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    final List<DetectedObject> objects = await objectDetector.processImage(inputImage);

    faceDetected.value = faces.isNotEmpty;
    objectDetected.value = objects.any((object) {
      return object.labels.any((label) => label.text.toLowerCase().contains('road') || label.text.toLowerCase().contains('house'));
    });

    boundingBoxes.value = [
      ...faces.map((face) => face.boundingBox),
      ...objects.map((object) => object.boundingBox),
    ];

    await faceDetector.close();
    await objectDetector.close();
    isDetecting = false;
  }

  Future<String?> capturePhoto() async {
    if (!faceDetected.value || !objectDetected.value) return null;
    final XFile file = await cameraController.takePicture();

    final directory = await getApplicationDocumentsDirectory();
    final savedPath = '${directory.path}/captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(file.path).copy(savedPath);

    return savedPath;
  }

  InputImage _convertCameraImage(CameraImage image) {
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: InputImageRotation.rotation270deg,  // Change this to match your camera orientation
      format: InputImageFormat.nv21,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      metadata: metadata,
    );
  }


  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

}