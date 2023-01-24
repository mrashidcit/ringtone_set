import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/db_services/favorite_database.dart';
import 'package:deeze_app/models/favorite.dart';
import 'package:deeze_app/uitilities/my_theme.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_share/social_share.dart';

import '../../../models/deeze_model.dart';

class ProfileRingtonesCard extends StatefulWidget {
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
  final Function(int) onTapDelete;
  ProfileRingtonesCard(
      {Key? key,
      required this.ringtoneName,
      required this.index,
      required this.file,
      required this.auidoId,
      required this.onTap,
      required this.onNavigate,
      required this.onChange,
      required this.onTapDelete,
      required this.audioPlayer,
      this.duration,
      this.isPlaying = false,
      this.isBuffering = false,
      this.position,
      this.listHydra})
      : super(key: key);

  @override
  State<ProfileRingtonesCard> createState() => _RingtonesCardState();
}

class _RingtonesCardState extends State<ProfileRingtonesCard> {
  // late AnimationController controller;
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
  Duration? lastPlayingPosition;
  // Whether the green box should be visible.
  bool _visible = true;
  double _width = 0.0;

  int selectedIndex = -1;

  refreshFavorite() async {
    favoriteList = await FavoriteDataBase.instance
        .readAllFavoriteOfCurrentMusic(widget.auidoId);
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshFavorite();
    // controller = AnimationController(
    //   vsync: this,
    //   duration: const Duration(seconds: 10),
    // )..addListener(() {
    //     setState(() {});
    //   });
    // controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var element = mygradientList[_random.nextInt(mygradientList.length)];

    if (widget.isPlaying) {
      print(
          '>> ringtones_card - build - widget.position : ${widget.position!.inMicroseconds.toDouble()}');
      // lastPlayingPosition = widget.position;
    } else {
      print(
          '>> ringtones_card - build - widget.position , isPlaying : ${widget.position!.inMicroseconds.toDouble()} , ${widget.isPlaying}');
    }

    return SliderTheme(
      data: SliderThemeData(
        // trackHeight: double.maxFinite,
        trackHeight: 200,
        thumbShape: SliderComponentShape.noOverlay,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: SliderComponentShape.noOverlay,
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          height: double.infinity,
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
            clipBehavior: Clip.antiAlias,
            children: [
              Slider(
                activeColor: Colors.white12,
                inactiveColor: Colors.transparent,
                min: 0,
                max: widget.duration!.inMicroseconds.toDouble(),
                value: getPositionValueForSlider(),
                onChanged: (value) async {
                  print(
                      '>> ringtones_card - slider - onchanged - value : $value');
                  // widget.onChange(value);
                },
              ),
              GestureDetector(
                // onTap: widget.onNavigate,
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      // color: MyTheme.orange,
                      borderRadius: BorderRadius.circular(6)),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    widget.onTap();
                    setState(() {
                      if (_width == 200)
                        _width = 0.0;
                      else
                        _width = 200;
                      // _visible = !_visible;
                    });
                  },
                  child: buildPlayAndPauseImage(),
                  // child: LoadingPage(),
                ),
              ),
              if (selectedIndex == widget.index)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

              Positioned(
                top: 10,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    if (selectedIndex != widget.index)
                      selectedIndex = widget.index;
                    else
                      selectedIndex = -1;
                    setState(() {});
                  },
                  child: const AppImageAsset(
                    image: 'assets/horizontal_more.svg',
                    height: 12,
                  ),
                ),
              ),
              // Delete Overlay
              if (selectedIndex == widget.index)
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          selectedIndex = -1;
                          widget.onTapDelete(widget.index);
                        },
                        child: Text(
                          'Delete',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          SocialShare.shareOptions(widget.file);
                        },
                        child: Text(
                          'Share',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double getPositionValueForSlider() {
    if (widget.position!.inMicroseconds.toDouble() <=
        widget.duration!.inMicroseconds.toDouble()) {
      return widget.position!.inMicroseconds.toDouble();
    } else {
      return widget.duration!.inMicroseconds.toDouble();
    }
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
