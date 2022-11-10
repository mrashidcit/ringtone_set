import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AfrimationPageManger {
  final progressNotifier = ValueNotifier<ProgressState>(
    ProgressState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<MyButtonState>(MyButtonState.paused);

  // static const url =
  //     'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';

  late AudioPlayer audioPlayer;
  AfrimationPageManger() {
    _init();
  }

  void _init() async {
    audioPlayer = AudioPlayer();

    audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = MyButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = MyButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = MyButtonState.playing;
      } else {
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
      }
    });

    audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });

    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });

    audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  void setURl(String url) async {
    await audioPlayer.setUrl(url);
  }

  void play() {
    audioPlayer.play();
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  void dispose() {
    audioPlayer.dispose();
  }

  void loop(LoopMode loopMode) {
    audioPlayer.setLoopMode(loopMode);
  }
}

class ProgressState {
  ProgressState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum MyButtonState { paused, playing, loading }
