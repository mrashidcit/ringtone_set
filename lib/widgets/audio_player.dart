import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:deeze_app/uitilities/end_points.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/child_widgets/build_play.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:platform_device_id/platform_device_id.dart';
import '../db_services/favorite_database.dart';
import '../models/deeze_model.dart';
import '../models/favorite.dart';
import 'app_loader.dart';
import 'audio_select_dialog.dart';
import 'more_audio_dialog.dart';
import 'package:http/http.dart' as http;

class CustomAudioPlayer extends StatefulWidget {
  List<DeezeItemModel> listHydra;
  final int index;

  CustomAudioPlayer({
    Key? key,
    required this.listHydra,
    required this.index,
  }) : super(key: key);

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  final CarouselController _controller = CarouselController();

  animateToSilde(int index) {
    return _controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  int page = 1;
  int? totalPage;

  ScrollController scrollController = ScrollController();
  bool isDataLoad = false;
  bool isLoading = false;

  Future<bool> fetchRingtone() async {
    var url = getDeezeAppHpUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      // "enabled": "true",
      "type": "RINGTONE"
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeItemModelFromJson(response.body);

        widget.listHydra.addAll(rawResponse);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  bool isPlaying = false;
  bool isBuffering = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.listHydra.removeRange(0, widget.index);
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => animateToSilde(widget.index));
    audioPlayer.onPlayerStateChanged.listen((state) {
      print(
          '>> audioPlayer.onPlayerStateChanged - state , mounted = ${state.name} , ${mounted}');
      if (state == PlayerState.PAUSED) {
        isPlaying = false;
      } else if (state == PlayerState.COMPLETED) {
        isPlaying = false;
        isBuffering = false;
      }
      if (mounted) {
        setState(() {
          // isPlaying = state == PlayerState.PLAYING;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((state) {
      isBuffering = false;
      isPlaying = true;
      print(
          '>> audioPlayer.onDurationChanged - _isBuffering , isPlaying : $isBuffering , $isPlaying ');

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
    // PlayerState.STOPPED;
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
    // print('>> build - CustomAudioPlayer - activeIndex = $activeIndex');
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(gradient: gradient),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25.0, sigmaY: 25.0),
          child: Stack(
            children: [
              const AppImageAsset(
                  image: 'assets/drop_shadow.png',
                  height: double.infinity,
                  fit: BoxFit.cover),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: widget.listHydra.length,
                    itemBuilder: (context, index, realIndex) {
                      final file = widget.listHydra[index].file;
                      final name = widget.listHydra[index].name;
                      myfile = index == 0
                          ? widget.listHydra[0].file!
                          : widget.listHydra[index - 1].file!;
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
                              ? buildActiveBuildPlay(index, context, file, name)
                              : buildNonActiveBuildPlay(
                                  index, context, file, name),
                          const SizedBox(height: 10),
                          if (activeIndex == index)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.05),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      widget.listHydra[activeIndex].user
                                                  ?.image !=
                                              null
                                          ? CircleAvatar(
                                              radius: 17,
                                              backgroundImage: NetworkImage(
                                                widget.listHydra[activeIndex]
                                                    .user!.image!,
                                              ),
                                            )
                                          : const CircleAvatar(
                                              backgroundColor: Colors.grey,
                                              radius: 15,
                                            ),
                                      const SizedBox(width: 12),
                                      Text(
                                        widget.listHydra[activeIndex].user!
                                            .firstName!,
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
                        print(
                            ">> CarouselOptions - onPageChanged - index : $index");
                        setState(() {
                          page = index;
                        });
                        // fetchRingtone();
                        if (isPlaying) {
                          await audioPlayer.pause();
                          // await audioPlayer.play(widget.listHydra[index].file!);
                        }
                        if (audioPlayer.state == PlayerState.PAUSED) {
                          await audioPlayer.release();
                        } else {
                          // await audioPlayer.pause();
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
                          print(
                              '>> CarouselOptions - onPageChanged : activeIndex = $activeIndex');
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
                                  userName: widget
                                      .listHydra[activeIndex].user!.firstName!,
                                  userImage: widget
                                      .listHydra[activeIndex].user!.image!,
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
                          print('>> onTap : myFile = $myfile');
                          showCupertinoModalPopup(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.8),
                            builder: (context) =>
                                AudioSelectDialog(file: myfile),
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

  BuildPlay buildNonActiveBuildPlay(
      int index, BuildContext context, String? file, String? name) {
    return BuildPlay(
      audioId: widget.listHydra[index].id.toString(),
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
      isFavourite: widget.listHydra[index].isFavourite,
      onTap: () => nonActivePlayAndPauseAction(context, index),
      audioPlayer: activeIndex == index ? audioPlayer : pausePlayer,
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      duration: activeIndex == index ? duration : pauseDuration,
      position: activeIndex == index ? position : pausePosition,
      // position: Duration(milliseconds: 0),
      activeIndex: activeIndex,
      file: file!,
      index: index,
      name: name!,
      userName: widget.listHydra[index].user!.firstName!,
      userProfileUrl: widget.listHydra[index].user!.image,
    );
  }

  BuildPlay buildActiveBuildPlay(
      int index, BuildContext context, String? file, String? name) {
    return BuildPlay(
      audioId: widget.listHydra[index].id.toString(),
      onChange: (value) async {
        final myposition = Duration(microseconds: value.toInt());
        await audioPlayer.seek(myposition);
        await audioPlayer.resume();
      },
      onTap: () => nonActivePlayAndPauseAction(context, index),
      onTapFavourite: () {
        setState(() {
          widget.listHydra[index].isFavourite =
              !widget.listHydra[index].isFavourite;
        });
      },
      isFavourite: widget.listHydra[index].isFavourite,
      audioPlayer: activeIndex == index ? audioPlayer : pausePlayer,
      isPlaying: isPlaying,
      isBuffering: isBuffering,
      duration: activeIndex == index ? duration : pauseDuration,
      position: activeIndex == index ? position : pausePosition,
      // position: Duration(milliseconds: 0),
      activeIndex: activeIndex,
      file: file!,
      index: index,
      name: name!,
      userName: widget.listHydra[index].user!.firstName!,
      userProfileUrl: widget.listHydra[index].user!.image,
    );
  }

  Future<void> nonActivePlayAndPauseAction(
      BuildContext context, int index) async {
    {
      // if (isPlaying) {
      // } else {}
      print(
          '>> nonActivePlayAndPauseAction - audioPlayer.state : ${audioPlayer.state.name} ');

      if (isPlaying || isBuffering) {
        await audioPlayer.pause();
        setState(() {
          isPlaying = false;
          isBuffering = false;
        });
      } else if (audioPlayer.state == PlayerState.PAUSED) {
        audioPlayer.resume();
        setState(() {
          isBuffering = false;
          isPlaying = true;
        });
      } else {
        bool hasInternet = await InternetConnectionChecker().hasConnection;
        print('>> hasInternet : $hasInternet');
        if (!await InternetConnectionChecker().hasConnection) {
          showCupertinoModalPopup(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => InternetCheckerDialog(onRetryTap: () {
              Navigator.pop(ctx); // Hide Internet Message Dialog
              Timer(Duration(milliseconds: 500),
                  () => nonActivePlayAndPauseAction(context, index));
            }),
          );
        } else {
          setState(() {
            isBuffering = true;
          });
          await audioPlayer.play(widget.listHydra[index].file!);
        }
        // await audioPlayer
        //     .play(widget.listHydra[index].file!);
      }
    }
  }

  // Future<void> activePlayAndPauseAction(BuildContext context, int index) async {
  //   {
  //     // if (isPlaying) {
  //     // } else {}

  //     print(
  //         '>> activePlayAndPauseAction : audioPlayer.state = ${audioPlayer.state}');

  //     setState(() {
  //       position = Duration.zero;
  //     });
  //     if (isPlaying || isBuffering) {
  //       await audioPlayer.pause();
  //       setState(() {
  //         isPlaying = false;
  //         isBuffering = false;
  //       });
  //     } else if (audioPlayer.state == PlayerState.PAUSED) {
  //       audioPlayer.resume();
  //     } else {
  //       bool hasInternet = await InternetConnectionChecker().hasConnection;
  //       print('>> hasInternet : $hasInternet');
  //       if (!await InternetConnectionChecker().hasConnection) {
  //         showCupertinoModalPopup(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (context) => InternetCheckerDialog(onRetryTap: () {
  //             print('>> onRetryTap');
  //             activePlayAndPauseAction(context, index);
  //           }),
  //         );
  //       } else {
  //         setState(() {
  //           isBuffering = true;
  //         });
  //         await audioPlayer.play(widget.listHydra[index].file!);
  //       }
  //     }
  //   }
  // }
}
