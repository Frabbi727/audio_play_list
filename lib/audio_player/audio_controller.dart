import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart' as rxdart;

import 'common.dart';

class AudioController extends GetxController {
  final AudioPlayer player = AudioPlayer();

  var isLoading = false.obs;
  var isPlaying = false.obs;
  var isCompleted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());

    player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      print('Stream error: $e');
    });

    try {
      await player.setAudioSource(AudioSource.uri(
        Uri.parse("https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3"),
      ));
    } catch (e) {
      print("Error loading audio source: $e");
    }

    player.playerStateStream.listen((state) {
      isLoading.value = state.processingState == ProcessingState.loading || state.processingState == ProcessingState.buffering;
      isPlaying.value = state.playing;
      isCompleted.value = state.processingState == ProcessingState.completed;
    });
  }

  // Expose position data stream to use in the SeekBar widget
  Stream<PositionData> get positionDataStream => rxdart.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
    player.positionStream,
    player.bufferedPositionStream,
    player.durationStream,
        (position, bufferedPosition, duration) => PositionData(position, bufferedPosition, duration ?? Duration.zero),
  );

  void play() => player.play();
  void pause() => player.pause();
  void stop() => player.stop();
  void seek(Duration position) => player.seek(position);

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}


