import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'audio_controller.dart';
import 'common.dart';

class ControlButtons extends StatelessWidget {
  final AudioController audioController = Get.find<AudioController>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "Adjust volume",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              value: audioController.player.volume,
              stream: audioController.player.volumeStream,
              onChanged: audioController.player.setVolume,
            );
          },
        ),
        Obx(() {
          if (audioController.isLoading.value) {
            return CircularProgressIndicator();
          } else if (!audioController.isPlaying.value) {
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 64.0,
              onPressed: audioController.play,
            );
          } else if (!audioController.isCompleted.value) {
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 64.0,
              onPressed: audioController.pause,
            );
          } else {
            return IconButton(
              icon: Icon(Icons.replay),
              iconSize: 64.0,
              onPressed: () => audioController.seek(Duration.zero),
            );
          }
        }),
        StreamBuilder<double>(
          stream: audioController.player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust speed",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                value: audioController.player.speed,
                stream: audioController.player.speedStream,
                onChanged: audioController.player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
