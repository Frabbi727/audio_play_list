import 'package:audio_player/audio_player/audio_controller.dart';
import 'package:get/get.dart';

class AudioBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(AudioController());
  }

}