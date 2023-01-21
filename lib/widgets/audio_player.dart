import 'dart:async';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/ad_helper.dart';
import 'package:deeze_app/repositories/item_repository.dart';
import 'package:deeze_app/uitilities/end_points.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/child_widgets/build_play.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:social_share/social_share.dart';
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
  final String type;
  bool loadCurrentUserItemsOnly = false;

  CustomAudioPlayer({
    Key? key,
    required this.listHydra,
    required this.index,
    required this.type,
    this.loadCurrentUserItemsOnly = false,
  }) : super(key: key);

  @override
  State<CustomAudioPlayer> createState() => _CustomAudioPlayerState();
}

class _CustomAudioPlayerState extends State<CustomAudioPlayer> {
  final CarouselController _controller = CarouselController();
  InterstitialAd? _interstitialAd;

  animateToSilde(int index) {
    return _controller.animateToPage(
      0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.linear,
    );
  }

  int page = 2;
  int? totalPage;

  ScrollController scrollController = ScrollController();
  bool isDataLoad = false;
  bool isLoading = false;
  BannerAd? _bannerAd;

  Future<bool> fetchData() async {
    if (widget.loadCurrentUserItemsOnly) {
      setState(() {});
      var itemResponse = await ItemRepository().getCurrentUserItemsResponse(
        itemType: widget.type == ItemType.RINGTONE.name
            ? ItemType.RINGTONE
            : ItemType.NOTIFICATION,
        pageNumber: page,
      );
      if (itemResponse.result) {
        if (itemResponse.itemList.length > 0) page++;
        widget.listHydra.addAll(itemResponse.itemList);
        setState(() {});
        if (itemResponse.itemList.isEmpty) {
          _noMoreDataFound = true;
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('No Data Found!'),
          ));
        }
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unable to load Data!'),
        ));
        return false;
      }
    } else {
      var url = getDeezeAppHpUrlContent;

      Uri uri = Uri.parse(url).replace(queryParameters: {
        "page": "$page",
        "itemsPerPage": "10",
        // "enabled": "true",
        // "type": "RINGTONE"
        "type": widget.type,
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

          if (rawResponse.length > 0) page++;

          setState(() {
            widget.listHydra.addAll(rawResponse);
          });

          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
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

  static final _kAdIndex = 4;
  BannerAd? _ad;
  bool _noMoreDataFound = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadInterstitialAd();
    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: AdRequest(),
      size: AdSize.banner,
      // size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    ).load();
    widget.listHydra.removeRange(0, widget.index);
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => animateToSilde(widget.index));
    audioPlayer.onPlayerStateChanged.listen((state) {
      print(
          '>> audioPlayer.onPlayerStateChanged - state , mounted = ${state.name} , ${mounted}');
      if (state == PlayerState.PAUSED) {
        isPlaying = false;
      } else if (state == PlayerState.STOPPED) {
        isPlaying = false;
        isBuffering = false;
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
      print(
          '>> audioPlayer.onDurationChanged - state , mounted = ${audioPlayer.state.name} , ${mounted}');
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
        isBuffering = false;
        isPlaying = true;
        position = state;
      });
    });

    BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _ad = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          // Releases an ad resource when it fails to load
          ad.dispose();
          print('Ad load failed (code=${error.code} message=${error.message})');
        },
      ),
    ).load();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _ad?.dispose();
    super.dispose();
    _bannerAd?.dispose();
    audioPlayer.dispose();
    isPlaying = false;
    // PlayerState.STOPPED;
  }

  int _getDestinationItemIndex(int rawIndex) {
    if (rawIndex >= _kAdIndex && _ad != null) {
      return rawIndex - 1;
    }
    return rawIndex;
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _moveToHome();
            },
          );

          setState(() {
            _interstitialAd = ad;
          });
        },
        onAdFailedToLoad: (err) {
          print('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
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

  _moveToHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // print('>> build - CustomAudioPlayer - activeIndex = $activeIndex');
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        if (_interstitialAd != null) {
          _interstitialAd?.show();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
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
                  fit: BoxFit.cover,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CarouselSlider.builder(
                      carouselController: _controller,
                      itemCount: widget.listHydra.length + 1,
                      itemBuilder: (context, index, realIndex) {
                        if (_ad != null && index == _kAdIndex) {
                          return buildCarouselItemForAd(
                              index, context, '', '', screenWidth);
                        } else if (index > widget.listHydra.length - 1) {
                          if (_noMoreDataFound) {
                            return buildCarouselItemForNoMoreDateFound(
                                context, screenWidth);
                          } else {
                            return buildCarouselItemForLoading(
                              context,
                              screenWidth,
                            );
                          }
                        } else {
                          final file = widget.listHydra[index].file;
                          final name = widget.listHydra[index].name;
                          print(
                              '>> CarouselSlider - itemBuilder - name , file : $name , $file');
                          // myfile = index == 0
                          //     ? widget.listHydra[0].file!
                          //     : widget.listHydra[index - 1].file!;
                          myfile = file!;
                          return buildCarouselItem(
                            index,
                            context,
                            file,
                            name,
                            screenWidth,
                          );
                        }
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
                            // page = index;
                          });
                          // fetchData();
                          if (isPlaying) {
                            await audioPlayer.pause();
                            // await audioPlayer.play(widget.listHydra[index].file!);
                          }
                          if (isBuffering) {
                            await audioPlayer.release();
                          } else if (audioPlayer.state == PlayerState.PAUSED) {
                            await audioPlayer.release();
                          } else {
                            // await audioPlayer.pause();
                          }
                          if (index > widget.listHydra.length - 1) {
                            setState(() {
                              gradient = (index % 4 == 0)
                                  ? myGradientList[0]
                                  : (index % 3 == 0)
                                      ? myGradientList[3]
                                      : (index % 2 == 0)
                                          ? myGradientList[4]
                                          : myGradientList[1];
                              position = Duration.zero;
                              // myfile = widget.listHydra[index].file!;
                              if (!_noMoreDataFound) fetchData();
                              activeIndex = index;
                              print(
                                  '>> CarouselOptions - onPageChanged : activeIndex = $activeIndex');
                            });
                          } else {
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
                          }
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
                              print(
                                  '>> audio_player - tags : ${widget.listHydra[activeIndex].tags}');
                              showCupertinoModalPopup(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.8),
                                builder: (context) {
                                  return MoreAudioDialog(
                                    file: myfile,
                                    fileName:
                                        widget.listHydra[activeIndex].name!,
                                    userName: widget.listHydra[activeIndex]
                                        .user!.firstName!,
                                    userImage: widget
                                        .listHydra[activeIndex].user!.image!,
                                    tags: widget.listHydra[activeIndex].tags,
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
                            var file = widget.listHydra[activeIndex].file;
                            var name = widget.listHydra[activeIndex].name;
                            // print('>> onTap : myFile = $myfile ');
                            print('>> onTap : name , file = $name , $file ');
                            showCupertinoModalPopup(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.8),
                              builder: (context) =>
                                  AudioSelectDialog(file: file!),
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
                        GestureDetector(
                          onTap: () {
                            var item = widget.listHydra![activeIndex];
                            SocialShare.shareOptions("${item.file!}");
                            ;
                          },
                          child: const AppImageAsset(
                            image: 'assets/share.svg',
                            height: 20,
                            width: 20,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                    if (_bannerAd != null)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
                                width: _bannerAd!.size.width.toDouble(),
                                height: _bannerAd!.size.height.toDouble(),
                                child: AdWidget(ad: _bannerAd!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Column buildCarouselItemForLoading(BuildContext context, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Loading ...',
          style: GoogleFonts.archivo(
            fontStyle: FontStyle.normal,
            color: Colors.white,
            fontSize: 20,
            wordSpacing: -0.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 30),
        LoadingPage(),
        const SizedBox(height: 10),
        const SizedBox(height: 45),
      ],
    );
  }

  Column buildCarouselItemForNoMoreDateFound(
      BuildContext context, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No More Data Found!',
          style: GoogleFonts.archivo(
            fontStyle: FontStyle.normal,
            color: Colors.white,
            fontSize: 20,
            wordSpacing: -0.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        // const SizedBox(height: 30),
        // LoadingPage(),
        // const SizedBox(height: 10),
        // const SizedBox(height: 45),
      ],
    );
  }

  Column buildCarouselItem(int index, BuildContext context, String? file,
      String? name, double screenWidth) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(child: Center()),
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
        // activeIndex == index
        //     ? buildActiveBuildPlay(index, context, file, name)
        //     : buildNonActiveBuildPlay(index, context, file, name),
        buildActiveBuildPlay(index, context, file, name),
        const SizedBox(height: 10),
        if (activeIndex == index)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    widget.listHydra[activeIndex].user?.image != null
                        ? CircleAvatar(
                            radius: 17,
                            backgroundImage: NetworkImage(
                              widget.listHydra[activeIndex].user!.image!,
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
  }

  Column buildCarouselItemForAd(int index, BuildContext context, String? file,
      String? name, double screenWidth) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Text(
        //   widget.listHydra[index].name!,
        //   style: GoogleFonts.archivo(
        //     fontStyle: FontStyle.normal,
        //     color: Colors.white,
        //     fontSize: 20,
        //     wordSpacing: -0.1,
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        const SizedBox(height: 10),
        // activeIndex == index
        //     ? buildActiveBuildPlay(index, context, file, name)
        //     : buildNonActiveBuildPlay(index, context, file, name),
        // buildActiveBuildPlay(index, context, file, name),
        // AdWidget(ad: _ad!),
        Container(
          width: _ad!.size.width.toDouble(),
          height: 272.0,
          alignment: Alignment.center,
          child: AdWidget(ad: _ad!),
        ),
        const SizedBox(height: 10),
      ],
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
      onTap: () => activePlayAndPauseAction(context, index),
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
      onTap: () => activePlayAndPauseAction(context, index),
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

  Future<void> activePlayAndPauseAction(BuildContext context, int index) async {
    {
      // if (isPlaying) {
      // } else {}
      print(
          '>> activePlayAndPauseAction - audioPlayer.state : ${audioPlayer.state.name} ');

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
                  () => activePlayAndPauseAction(context, index));
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
}
