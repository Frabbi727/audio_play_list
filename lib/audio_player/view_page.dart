import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'audio_controller.dart';
import 'common.dart';
import 'controll_button.dart';



class AudioPlayerView extends StatelessWidget {
  final AudioController audioController = Get.put(AudioController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ControlButtons(),
               StreamBuilder<PositionData>(
                stream: audioController.positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return SeekBar(
                    duration: positionData?.duration ?? Duration.zero,
                    position: positionData?.position ?? Duration.zero,
                    bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                    onChangeEnd: audioController.seek,
                  );
                },
              ),


          ],
        ),
      ),
    );
  }
}
