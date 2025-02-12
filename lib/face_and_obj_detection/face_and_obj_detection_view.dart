import 'package:audio_player/face_and_obj_detection/face_and_obj_detection_controller.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaceAndObjDetectionView extends GetView<FaceAndObjDetectionController> {
   FaceAndObjDetectionView({super.key});
  final FaceAndObjDetectionController controller = Get.put(FaceAndObjDetectionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-Time Detection')),
      body: Obx(() {
        if (!controller.isInitialized.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            CameraPreview(controller.cameraController),
            ...controller.boundingBoxes.map((rect) => Positioned(
              left: rect.left,
              top: rect.top,
              width: rect.width,
              height: rect.height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.faceDetected.value && controller.objectDetected.value
                        ? Colors.green
                        : Colors.red,
                    width: 2,
                  ),
                ),
              ),
            )),
            Positioned(
              bottom: 50,
              left: 50,
              child: ElevatedButton(
                onPressed: controller.faceDetected.value && controller.objectDetected.value
                    ? () async {
                  final savedPath = await controller.capturePhoto();
                  if (savedPath != null) {
                    Get.snackbar('Photo Saved', 'Saved to: $savedPath');
                  } else {
                    Get.snackbar('Error', 'Face and Object not detected properly');
                  }
                }
                    : null,
                child: Text('Capture Photo'),
              ),
            ),
          ],
        );
      }),
    );
  }
}
