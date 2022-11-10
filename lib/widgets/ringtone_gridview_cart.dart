import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/db_services/favorite_database.dart';
import 'package:deeze_app/models/favorite.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/deeze_model.dart';

class RingtoneGridviewCard extends StatelessWidget {
  final List<DeezeItemModel>? listHydra;
  final int index;
  final String ringtoneName;
  final String file;
  final String auidoId;
  Duration? duration;
  Duration? position;
  final AudioPlayer audioPlayer;
  bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onRefresh;
  final VoidCallback onNavigate;
  final Function(double) onChange;
  RingtoneGridviewCard(
      {Key? key,
      required this.ringtoneName,
      required this.onRefresh,
      required this.index,
      required this.file,
      required this.auidoId,
      required this.onTap,
      required this.onNavigate,
      required this.onChange,
      required this.audioPlayer,
      this.duration,
      this.isPlaying = false,
      this.position,
      this.listHydra})
      : super(key: key);
  List mygradientList = const [
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF289987),
          Color(0xFF727b64),
        ]),
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF5951af),
          Color(0xFF5f5b8c),
        ]),
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF5d8897),
          Color(0xFF4f4d7e),
        ]),
    LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF5048dd),
          Color(0xFF89c0d3),
        ]),
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF5952af),
          Color(0xFF5e5b8c),
        ]),
  ];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 235,
        thumbShape: SliderComponentShape.noOverlay,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: SliderComponentShape.noOverlay,
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: Container(
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: (index % 4 == 0)
              ? mygradientList[0]
              : (index % 3 == 0)
                  ? mygradientList[3]
                  : (index % 2 == 0)
                      ? mygradientList[4]
                      : mygradientList[1],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            Slider(
              activeColor: Colors.white12,
              inactiveColor: Colors.transparent,
              min: 0,
              max: duration!.inMicroseconds.toDouble(),
              value: position!.inMicroseconds.toDouble(),
              onChanged: (value) async {
                // onChange(value);
              },
            ),
            GestureDetector(
              onTap: onTap,
              child: Align(
                alignment: Alignment.center,
                child: AppImageAsset(
                  image: isPlaying ? 'assets/pause.svg' : 'assets/play.svg',
                  height: 50,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                "${ringtoneName}",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: (() async {
                String? deviceId = await PlatformDeviceId.getDeviceId;

                await FavoriteDataBase.instance.delete(auidoId);

                onRefresh();
              }),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: AppImageAsset(
                    image: "assets/favourite_fill.svg",
                    color: Colors.red,
                    height: 16,
                    width: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
