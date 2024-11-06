import 'package:audio_player/play_list/play_list_controll_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../audio_player/common.dart';

import 'audio_meta_data.dart';
import 'audio_playlist_controller.dart';

class PlayListView extends StatelessWidget {
  final PlayListAudioPlayerController controller = Get.put(PlayListAudioPlayerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Audio Playlist')),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
          Expanded(child:   StreamBuilder<SequenceState?>(
            stream: controller.player.sequenceStateStream,
            builder: (context, snapshot) {
              final state = snapshot.data;
              if (state?.sequence.isEmpty ?? true) {
                return const SizedBox();
              }
              final metadata = state!.currentSource!.tag as AudioMetadata;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(child: Image.network(metadata.artwork)),
                    ),
                  ),
                  Text(metadata.album),
                  Text(metadata.title),
                ],
              );
            },
          ),),
            PlayListControlButtons(controller.player),
            StreamBuilder<PositionData>(
              stream: controller.positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return SeekBar(
                  duration: positionData?.duration ?? Duration.zero,
                  position: positionData?.position ?? Duration.zero,
                  bufferedPosition: positionData?.bufferedPosition ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    controller.player.seek(newPosition);
                  },
                );
              },
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                StreamBuilder<LoopMode>(
                  stream: controller.player.loopModeStream,
                  builder: (context, snapshot) {
                    final loopMode = snapshot.data ?? LoopMode.off;
                    const icons = [
                      Icon(Icons.repeat, color: Colors.grey),
                      Icon(Icons.repeat, color: Colors.orange),
                      Icon(Icons.repeat_one, color: Colors.orange),
                    ];
                    const cycleModes = [
                      LoopMode.off,
                      LoopMode.all,
                      LoopMode.one,
                    ];
                    final index = cycleModes.indexOf(loopMode);
                    return IconButton(
                      icon: icons[index],
                      onPressed: () {
                        controller.player.setLoopMode(cycleModes[
                        (cycleModes.indexOf(loopMode) + 1) %
                            cycleModes.length]);
                      },
                    );
                  },
                ),
                Expanded(
                  child: Text(
                    "Playlist",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                StreamBuilder<bool>(
                  stream: controller.player.shuffleModeEnabledStream,
                  builder: (context, snapshot) {
                    final shuffleModeEnabled = snapshot.data ?? false;
                    return IconButton(
                      icon: shuffleModeEnabled
                          ? const Icon(Icons.shuffle, color: Colors.orange)
                          : const Icon(Icons.shuffle, color: Colors.grey),
                      onPressed: () async {
                        final enable = !shuffleModeEnabled;
                        if (enable) {
                          await controller.player.shuffle();
                        }
                        await controller.player.setShuffleModeEnabled(enable);
                      },
                    );
                  },
                ),
              ],
            ),
            SizedBox(
              height: 240.0,
              child: StreamBuilder<SequenceState?>(
                stream: controller.player.sequenceStateStream,
                builder: (context, snapshot) {
                  final state = snapshot.data;
                  final sequence = state?.sequence ?? [];
                  return ReorderableListView(
                    onReorder: (int oldIndex, int newIndex) {
                      if (oldIndex < newIndex) newIndex--;
                      controller.playlist.move(oldIndex, newIndex);
                    },
                    children: [
                      for (var i = 0; i < sequence.length; i++)
                        Dismissible(
                          key: ValueKey(sequence[i]),
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                          ),
                          onDismissed: (dismissDirection) {
                            controller.playlist.removeAt(i);
                          },
                          child: Material(
                            color: i == state!.currentIndex
                                ? Colors.grey.shade300
                                : null,
                            child: ListTile(
                              title: Text(sequence[i].tag.title as String),
                              onTap: () {
                                controller.player.seek(Duration.zero, index: i);
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: controller.addAudioSource,
      ),
    );
  }
}


