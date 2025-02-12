import 'package:audio_player/face_and_obj_detection/face_and_obj_detection_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/bindings_interface.dart';

class FaceAndObjDetectionBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(FaceAndObjDetectionController());
  }

}