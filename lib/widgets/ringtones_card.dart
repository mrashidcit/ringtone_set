import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/db_services/favorite_database.dart';
import 'package:deeze_app/models/favorite.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/deeze_model.dart';

class RingtonesCard extends StatefulWidget {
  final List<DeezeItemModel>? listHydra;
  final int index;
  final String ringtoneName;
  final String file;
  final String auidoId;
  Duration? duration;
  Duration? position;
  final AudioPlayer audioPlayer;
  bool isPlaying;
  bool isBuffering;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final Function(double) onChange;
  RingtonesCard(
      {Key? key,
      required this.ringtoneName,
      required this.index,
      required this.file,
      required this.auidoId,
      required this.onTap,
      required this.onNavigate,
      required this.onChange,
      required this.audioPlayer,
      this.duration,
      this.isPlaying = false,
      this.isBuffering = false,
      this.position,
      this.listHydra})
      : super(key: key);

  @override
  State<RingtonesCard> createState() => _RingtonesCardState();
}

class _RingtonesCardState extends State<RingtonesCard> {
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
  final _random = Random();
  List<Favorite> favoriteList = [];

  refreshFavorite() async {
    favoriteList = await FavoriteDataBase.instance
        .readAllFavoriteOfCurrentMusic(widget.auidoId);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshFavorite();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var element = mygradientList[_random.nextInt(mygradientList.length)];

    return GestureDetector(
      onTap: widget.onNavigate,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 70,
          thumbShape: SliderComponentShape.noOverlay,
          overlayShape: SliderComponentShape.noOverlay,
          valueIndicatorShape: SliderComponentShape.noOverlay,
          trackShape: const RectangularSliderTrackShape(),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Container(
            height: 70,
            width: screenWidth,
            decoration: BoxDecoration(
              gradient: (widget.index % 4 == 0)
                  ? mygradientList[0]
                  : (widget.index % 3 == 0)
                      ? mygradientList[3]
                      : (widget.index % 2 == 0)
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
                  max: widget.duration!.inMicroseconds.toDouble(),
                  value: (widget.position!.inMicroseconds.toDouble() <=
                          widget.duration!.inMicroseconds.toDouble())
                      ? widget.position!.inMicroseconds.toDouble()
                      : widget.duration!.inMicroseconds.toDouble(),
                  onChanged: (value) async {
                    // widget.onChange(value);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: widget.onTap,
                            child: buildPlayAndPauseImage(),
                            // child: LoadingPage(),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Text(
                            widget.ringtoneName,
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 14,
                              wordSpacing: -0.07,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: (() async {
                              String? deviceId =
                                  await PlatformDeviceId.getDeviceId;

                              Favorite favorite = Favorite(
                                  name: widget.ringtoneName,
                                  currentDeviceId: deviceId!,
                                  path: widget.file,
                                  deezeId: widget.auidoId,
                                  type: "MUSIC");
                              favoriteList.isEmpty
                                  ? await FavoriteDataBase.instance
                                      .addFavorite(favorite)
                                  : await FavoriteDataBase.instance
                                      .delete(favoriteList.first.deezeId);
                              refreshFavorite();
                            }),
                            child: favoriteList.isEmpty
                                ? const AppImageAsset(
                                    image: 'assets/favourite.svg', height: 16)
                                : const AppImageAsset(
                                    image: "assets/favourite_fill.svg",
                                    color: Colors.red,
                                    height: 16,
                                    width: 16,
                                  ),
                          ),
                          const SizedBox(height: 7),
                          Row(
                            // ignore: prefer_const_literals_to_create_immutables
                            children: [
                              const AppImageAsset(
                                  image: 'assets/save_down.svg', height: 10),
                              SizedBox(width: 2),
                              Text(
                                "23K",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  wordSpacing: -0.07,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPlayAndPauseImage() {
    // print(
    //     '>> buildPlayAndPauseImage - position , duration : ${widget.position!.inMilliseconds} , ${widget.duration!.inMilliseconds} , ');
    if (widget.isBuffering) {
      return LoadingPage();
    } else {
      return AppImageAsset(
        image: widget.isPlaying ? 'assets/pause.svg' : 'assets/play.svg',
        height: 50,
      );
    }
  }
}
