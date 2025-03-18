import 'package:audio_player/multi_type_file/multy_type_file.dart';
import 'package:get/get.dart';

class MultiTypeBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(FileController());
  }

}