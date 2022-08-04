import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioServicesController extends GetxController {
  final audioPlayer = AudioPlayer();
  var isPlaying = false.obs;
  Rx<Duration> duration = Duration.zero.obs;
  Rx<Duration> position = Duration.zero.obs;
  void initialize(BuildContext context) async {
    audioPlayer.onDurationChanged.listen((state) {
      duration = state as Rx<Duration>;
    });
    audioPlayer.onAudioPositionChanged.listen((state) {
      position = state as Rx<Duration>;
    });
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.PLAYING) {
        isPlaying(true);
      } else {
        isPlaying(false);
      }
    });
  }

  void dispose() async {
    audioPlayer.dispose();
    isPlaying(false);
    PlayerState.STOPPED;
    audioPlayer.stop();
  }
}
