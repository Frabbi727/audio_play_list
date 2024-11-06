import 'package:get/get.dart';

import 'audio_playlist_controller.dart';

class PlayListBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(PlayListAudioPlayerController());
  }

}