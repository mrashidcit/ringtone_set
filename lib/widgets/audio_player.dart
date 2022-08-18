import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/deeze_model.dart';
import 'audio_select_dialog.dart';
import 'more_audio_dialog.dart';

class CustomAudioPlayer extends StatefulWidget {
  final List<HydraMember> listHydra;
  final int index;

  const CustomAudioPlayer({
    Key? key,
    required this.listHydra,
    required this.index,
  }) : super(key: key);

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  final CarouselController _controller = CarouselController();

  animateToSilde(int index) => _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 100),
        curve: Curves.linear,
      );

  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => animateToSilde(widget.index));
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });
    audioPlayer.onDurationChanged.listen((state) {
      setState(() {
        duration = state;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((state) {
      setState(() {
        position = state;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
    isPlaying = false;
    PlayerState.STOPPED;
  }

  late int activeIndex = widget.index;
  String myfile = "";
  List myGradientList = const [
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF289987),
        Color(0xFF727b64),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5951af),
        Color(0xFF5f5b8c),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5d8897),
        Color(0xFF4f4d7e),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF5048dd),
        Color(0xFF89c0d3),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5952af),
        Color(0xFF5e5b8c),
      ],
    ),
  ];
  Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: gradient),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Stack(
            children: [
              const AppImageAsset(image: 'assets/drop_shadow.png', height: double.infinity, fit: BoxFit.cover),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: widget.listHydra.length,
                    itemBuilder: (context, index, realIndex) {
                      final file = widget.listHydra[index].file;
                      final name = widget.listHydra[index].name;
                      // myfile = index == 0
                      //     ? widget.listHydra[0].file!
                      //     : widget.listHydra[index - 1].file!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.listHydra[index].name!,
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 20,
                              wordSpacing: -0.1,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          activeIndex == index
                              ? BuildPlay(
                            onChange: (value) async {
                              final myposition = Duration(microseconds: value.toInt());
                              await audioPlayer.seek(myposition);
                              await audioPlayer.resume();
                            },
                            onTap: (() async {
                              // if (isPlaying) {
                              // } else {}

                              setState(() {
                                position = Duration.zero;
                              });
                              await audioPlayer.pause();
                              if (isPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer
                                    .play(widget.listHydra[index].file!);
                              }
                            }),
                            onTapFavourite: () {
                              setState(() {
                                widget.listHydra[index].isFavourite =
                                !widget.listHydra[index].isFavourite;
                              });
                            },
                            isFavourite: widget.listHydra[index].isFavourite,
                            audioPlayer: activeIndex == index
                                ? audioPlayer
                                : pausePlayer,
                            isPlaying: activeIndex == index ? isPlaying : false,
                            duration:
                            activeIndex == index ? duration : pauseDuration,
                            position:
                            activeIndex == index ? position : pausePosition,
                            activeIndex: activeIndex,
                            file: file!,
                            index: index,
                            name: name!,
                            userName: widget.listHydra[index].user!.firstName!,
                            userProfileUrl: widget.listHydra[index].user!.image,
                          )
                              : BuildPlay(
                                  onChange: (value) async {
                                    final myposition = Duration(microseconds: value.toInt());
                                    await audioPlayer.seek(myposition);
                                    await audioPlayer.resume();
                                  },
                                  onTapFavourite: () {
                                    setState(() {
                                      widget.listHydra[index].isFavourite =
                                          !widget.listHydra[index].isFavourite;
                                    });
                                  },
                                  isFavourite:
                                      widget.listHydra[index].isFavourite,
                                  onTap: (() async {
                                    // if (isPlaying) {
                                    // } else {}

                              if (isPlaying) {
                                await audioPlayer.pause();
                              } else {
                                await audioPlayer
                                    .play(widget.listHydra[index].file!);
                              }
                            }),
                            audioPlayer: activeIndex == index
                                ? audioPlayer
                                : pausePlayer,
                            isPlaying: activeIndex == index ? isPlaying : false,
                            duration:
                            activeIndex == index ? duration : pauseDuration,
                            position:
                            activeIndex == index ? position : pausePosition,
                            activeIndex: activeIndex,
                            file: file!,
                            index: index,
                            name: name!,
                            userName: widget.listHydra[index].user!.firstName!,
                            userProfileUrl: widget.listHydra[index].user!.image,
                          ),
                          const SizedBox(height: 10),
                          if (activeIndex == index)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      widget.listHydra[activeIndex].user?.image != null
                                          ? CircleAvatar(
                                              radius: 17,
                                              backgroundImage: NetworkImage(
                                                widget.listHydra[activeIndex].user!
                                                    .image!,
                                              ),
                                            )
                                          : const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              radius: 15,
                                            ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.listHydra[activeIndex].user!.firstName!,
                                        style: GoogleFonts.archivo(
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                          fontSize: 13,
                                          wordSpacing: -0.05,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const AppImageAsset(
                                        image: 'assets/arrow.svg',
                                        height: 8,
                                        width: 8,
                                        fit: BoxFit.fill,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        "23k",
                                        style: GoogleFonts.archivo(
                                          fontSize: 11,
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 45),
                        ],
                      );
                    },
                    options: CarouselOptions(
                      height: 450,
                      pageSnapping: true,
                      viewportFraction: 0.75,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                          await audioPlayer.play(widget.listHydra[index].file!);
                        } else {
                          await audioPlayer.pause();
                        }
                        setState(() {
                          gradient = (index % 4 == 0)
                              ? myGradientList[0]
                              : (index % 3 == 0)
                                  ? myGradientList[3]
                                  : (index % 2 == 0)
                                      ? myGradientList[4]
                                      : myGradientList[1];
                          position = Duration.zero;
                          myfile = widget.listHydra[index].file!;
                          activeIndex = index;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: GestureDetector(
                          onTap: () {
                            showCupertinoModalPopup(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.8),
                              builder: (context) {
                                return MoreAudioDialog(
                                  file: myfile,
                                  fileName: widget.listHydra[activeIndex].name!,
                                  userName: widget.listHydra[activeIndex].user!.firstName!,
                                  userImage: widget.listHydra[activeIndex].user!.image!,
                                );
                              },
                            );
                          },
                          child: const AppImageAsset(
                            image: 'assets/dot.svg',
                            height: 5,
                            width: 5,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.8),
                            builder: (context) => AudioSelectDialog(file: myfile),
                          );
                        },
                        child: Container(
                          height: 60,
                          width: 60,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: const AppImageAsset(
                            image: 'assets/call.svg',
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      const AppImageAsset(
                        image: 'assets/share.svg',
                        height: 20,
                        width: 20,
                        fit: BoxFit.cover,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BuildPlay extends StatefulWidget {
  final String file;
  final String name;
  final String userName;
  final String? userProfileUrl;
  final int index;
  final int activeIndex;
  Duration? duration;
  Duration? position;
  final AudioPlayer audioPlayer;
  bool isPlaying;
  bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onTapFavourite;
  final Function(double) onChange;

  BuildPlay(
      {Key? key,
      this.duration,
      this.position,
      required this.audioPlayer,
      required this.isPlaying,
      required this.onTap,
      required this.onTapFavourite,
      required this.onChange,
      required this.file,
      required this.name,
      required this.index,
      required this.userName,
      this.userProfileUrl,
      required this.isFavourite,
      required this.activeIndex})
      : super(key: key);

  @override
  State<BuildPlay> createState() => _BuildPlayState();
}

class _BuildPlayState extends State<BuildPlay> {
  List myGradientList = const [
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF289987),
        Color(0xFF727b64),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5951af),
        Color(0xFF5f5b8c),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5d8897),
        Color(0xFF4f4d7e),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF5048dd),
        Color(0xFF89c0d3),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5952af),
        Color(0xFF5e5b8c),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: widget.activeIndex == widget.index ? 254 : 0,
        thumbShape: SliderComponentShape.noOverlay,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: SliderComponentShape.noOverlay,
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: Container(
        height: 254,
        width: 254,
        decoration: BoxDecoration(
          gradient: (widget.index % 4 == 0)
              ? myGradientList[0]
              : (widget.index % 3 == 0)
                  ? myGradientList[3]
                  : (widget.index % 2 == 0)
                      ? myGradientList[4]
                      : myGradientList[1],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            Slider(
              activeColor: Colors.white12,
              inactiveColor: Colors.transparent,
              min: 0,
              max: widget.duration!.inMicroseconds.toDouble(),
              value: widget.position!.inMicroseconds.toDouble(),
              onChanged: (value) async {
                // widget.onChange(value);
              },
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Align(
                alignment: Alignment.center,
                child: AppImageAsset(
                  image:
                      widget.isPlaying ? 'assets/pause.svg' : 'assets/play.svg',
                  height: 90,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: widget.activeIndex == widget.index
                  ? GestureDetector(
                      onTap: widget.onTapFavourite,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 15, right: 15),
                        child: Align(
                            alignment: Alignment.bottomRight,
                            child: !widget.isFavourite
                                ? const AppImageAsset(
                                    image: "assets/favourite.svg")
                                : const AppImageAsset(
                                    image: "assets/favourite_fill.svg",
                                    height: 17,
                                    width: 17,
                                  )),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
