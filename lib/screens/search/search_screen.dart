import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/models/search_model.dart';
import 'package:deeze_app/uitilities/constants.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import '../../models/deeze_model.dart';
import '../../services/search_services.dart';
import '../../uitilities/end_points.dart';
import '../../widgets/audio_player.dart';
import '../../widgets/category_card.dart';
import '../../widgets/ringtones_card.dart';

class SearchScreen extends StatefulWidget {
  final String searchText;
  final String itemType;

  const SearchScreen({
    Key? key,
    required this.searchText,
    required this.itemType,
  }) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchServices _searchServices = SearchServices();
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  int? selectedIndex;
  bool isPlaying = false;
  bool isBuffering = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;
  ScrollController scrollController = ScrollController();
  ScrollController scrollControllerForRingtoneListView = ScrollController();

  final TextEditingController _typeAheadController = TextEditingController();

  bool isLoading = false;

  // **Ringtone
  bool isRingtone = false;
  bool isRingtoneDataLoad = false;
  int ringtonePage = 1;
  int? ringtoneTotalPage;
  final RefreshController _ringtoneRefreshController =
      RefreshController(initialRefresh: true);

  List<DeezeItemModel> ringtonelist = [];

  // **Notifications
  bool _isNotification = false;
  bool _isNotificationDataLoad = false;
  int _notificationPage = 1;
  int? _notificationTotalPage;
  final RefreshController _notificationRefreshController =
      RefreshController(initialRefresh: true);
  List<DeezeItemModel> _notificationList = [];

  // **Wallpaper
  bool isWallpaper = false;
  int wallpaperPage = 1;
  bool isWallPaperDataLoad = false;
  int? wallpaperTotalPage;
  final RefreshController _wallpaperRefreshController =
      RefreshController(initialRefresh: true);
  List<DeezeItemModel> wallpaperList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _typeAheadController.text = widget.searchText;

    if (widget.itemType == ItemType.RINGTONE.name) {
      isRingtone = true;
    } else if (widget.itemType == ItemType.NOTIFICATION.name) {
      _isNotification = true;
    } else if (widget.itemType == ItemType.WALLPAPER.name) {
      isWallpaper = true;
    }

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          if (isWallpaper) {
            isWallPaperDataLoad = true;
          } else if (isRingtone) {
            isRingtoneDataLoad = true;
          } else if (_isNotification) {
            _isNotificationDataLoad = true;
          }
        });
      }
    });
    liseten();
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
      isBuffering = false;
      isPlaying = true;
      if (mounted) {
        setState(() {
          duration = state;
        });
      }
    });
    audioPlayer.onAudioPositionChanged.listen((state) {
      setState(() {
        isBuffering = false;
        isPlaying = true;
        position = state;
      });
    });
  }

  void liseten() async {
    audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.PLAYING;
        });
      }
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

  Future<bool> fetchRingtone({bool isRefresh = false}) async {
    print(
        '>> fetchRingtone - isRefresh , ringtoneTotalPage : $isRefresh , $ringtoneTotalPage');
    if (isRefresh) {
      ringtonePage = 1;
    } else {
      if (ringtoneTotalPage == 0) {
        _ringtoneRefreshController.loadNoData();
        return false;
      }
    }

    // var url = getDeezeAppUrlContent;
    var url = getDeezeAppSearchItemsUrl;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$ringtonePage",
      "itemsPerPage": "${Constants.ItemsPerPage}",
      // "enabled": "true",
      "term": widget.searchText,
      "type": ItemType.RINGTONE.name
    });
    try {
      if (isRefresh) setState(() => isLoading = true);
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeItemModelFromSearchQueryJson(response.body);
        if (isRefresh) {
          ringtonelist = rawResponse;
        } else {
          ringtonelist.addAll(rawResponse);
        }

        ringtonePage++;
        ringtoneTotalPage = rawResponse.length;
        setState(() {
          isLoading = false;
          if (isRingtoneDataLoad && ringtoneTotalPage == 0) {
            showMessage(context, message: 'No data available!');
          }
          isRingtoneDataLoad = false;
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> fetchNotifications({bool isRefresh = false}) async {
    if (isRefresh) {
      _notificationPage = 1;
    } else {
      if (_notificationTotalPage == 0) {
        _notificationRefreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppSearchItemsUrl;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$_notificationPage",
      "itemsPerPage": "10",
      // "enabled": "true",
      "term": widget.searchText,
      "type": ItemType.NOTIFICATION.name
    });
    try {
      if (isRefresh) setState(() => isLoading = true);
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(
          '>> fetchNotifications - ${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print('>> fetchNotifications - body : ${response.body}');
        var rawResponse = deezeItemModelFromSearchQueryJson(response.body);
        if (isRefresh) {
          _notificationList = rawResponse;
        } else {
          _notificationList.addAll(rawResponse);
        }

        _notificationPage++;
        _notificationTotalPage = rawResponse.length;
        // json.decode(response.body)['found']['types'].map((json) {
        //   print(
        //     ">> fetchNotifications - json['name'] : ${json['name']}");
        //   if (json['name'] == 'NOTIFICATION')
        //     _notificationTotalPage = json['name'] / Constants.ItemsPerPage;
        // });
        // print(
        //     '>> fetchNotifications - $_notificationTotalPage : $_notificationTotalPage');
        setState(() {
          isLoading = false;
          if (_isNotificationDataLoad && _notificationTotalPage == 0) {
            showMessage(context, message: 'No data available!');
          }
          _isNotificationDataLoad = false;
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('>> fetchNotifications - ${e.toString()}');
      return false;
    }
  }

///////////////////////

  Future<bool> fetchWallpaper({bool isRefresh = false}) async {
    if (isRefresh) {
      wallpaperPage = 1;
    } else {
      if (wallpaperTotalPage == 0) {
        _wallpaperRefreshController.loadNoData();
        return false;
      }
    }

    // var url = getDeezeAppUrlContent;
    var url = getDeezeAppSearchItemsUrl;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$wallpaperPage",
      "itemsPerPage": "10",
      // "enabled": "true",
      "term": widget.searchText,
      "type": ItemType.WALLPAPER.name
    });
    try {
      if (isRefresh) setState(() => isLoading = true);
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeItemModelFromSearchQueryJson(response.body);
        if (isRefresh) {
          wallpaperList = rawResponse;
        } else {
          wallpaperList.addAll(rawResponse);
        }

        wallpaperPage++;
        wallpaperTotalPage = rawResponse.length;
        setState(() {
          isLoading = false;
          if (isWallPaperDataLoad && wallpaperTotalPage == 0) {
            showMessage(context, message: 'No data available!');
          }
          isWallPaperDataLoad = false;
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 60),
        child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF4d047d),
            elevation: 0,
            centerTitle: true,
            title: SizedBox(
              height: 43,
              width: MediaQuery.of(context).size.width,
              child: TypeAheadFormField<SearchModel?>(
                  suggestionsBoxVerticalOffset: 0,
                  suggestionsBoxDecoration:
                      const SuggestionsBoxDecoration(color: Colors.white),
                  suggestionsCallback: _searchServices.search,
                  debounceDuration: const Duration(milliseconds: 500),
                  // hideSuggestionsOnKeyboardHide: false,
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController,
                    decoration: const InputDecoration(
                      hintText: "",
                      hintStyle: TextStyle(
                        color: Color(0xFF5d318c),
                        fontSize: 12,
                      ),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 20,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(7),
                            topRight: Radius.circular(7)),
                        borderSide:
                            BorderSide(color: Color(0xFF5d318c), width: 0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                        borderSide:
                            BorderSide(color: Color(0xFF5d318c), width: 0.0),
                      ),
                      suffixIcon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: AppImageAsset(
                          image: 'assets/search.svg',
                          height: 10,
                          width: 10,
                          fit: BoxFit.fill,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  itemBuilder: (context, SearchModel? suggestion) {
                    final ringtone = suggestion!;
                    return GestureDetector(
                      onTap: (() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchScreen(
                              searchText: _typeAheadController.text,
                              itemType: widget.itemType,
                            ),
                          ),
                        );
                      }),
                      child: Padding(
                          padding: const EdgeInsets.only(left: 30, top: 10),
                          child: Text(
                            "${ringtone.name}",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: const Color(0xFF5d318c),
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                    );
                  },
                  onSuggestionSelected: (SearchModel? suggestion) {},
                  noItemsFoundBuilder: (context) => Center(
                        child: Text(
                          "No Found",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: const Color(0xFF5d318c),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  errorBuilder: (BuildContext context, error) {
                    return Center(
                      child: Text(
                        "Please enter ",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: const Color(0xFF5d318c),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }),
            )),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF4d047d),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
              ]),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 30,
            ),
            buildTabsBar(),
            const SizedBox(height: 25),
            isRingtone
                ? Expanded(
                    child: SmartRefresher(
                      enablePullUp: true,
                      controller: _ringtoneRefreshController,
                      onRefresh: () async {
                        print('>> SmartRefresher - onRefresh - ringtone ');
                        final result = await fetchRingtone(isRefresh: true);
                        print(
                            '>> SmartRefresher - onRefresh - ringtone - result : $result ');
                        if (result) {
                          _ringtoneRefreshController.refreshCompleted();
                        } else {
                          _ringtoneRefreshController.refreshFailed();
                        }
                      },
                      onLoading: () async {
                        print('>> SmartRefresher - onLoading - rintone ');
                        final result = await fetchRingtone();
                        if (result) {
                          _ringtoneRefreshController.loadComplete();
                        } else {
                          _ringtoneRefreshController.loadFailed();
                        }
                      },
                      header:
                          CustomHeader(builder: (context, mode) => Container()),
                      footer: CustomFooter(builder: (context, mode) {
                        print(
                            '>> CustomFooter - Rintone - isRingtoneDataLoad , ringtoneTotalPage : $isRingtoneDataLoad , $ringtoneTotalPage');
                        return isRingtoneDataLoad && ringtoneTotalPage != 0
                            ? const LoadingPage()
                            : const SizedBox();
                      }),
                      child: isLoading
                          ? const LoadingPage()
                          : ListView.builder(
                              itemCount: ringtonelist.length,
                              // controller: scrollController,
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                // return selectedIndex == index
                                //     ?
                                return RingtonesCard(
                                  onNavigate: () async {
                                    await audioPlayer.stop();
                                    setState(() {
                                      position = Duration.zero;
                                    });
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CustomAudioPlayer(
                                          listHydra: ringtonelist,
                                          index: index,
                                          type: widget.itemType,
                                        ),
                                      ),
                                    );
                                  },
                                  onChange: (value) async {
                                    final myposition =
                                        Duration(seconds: value.toInt());
                                    await audioPlayer.seek(myposition);
                                    await audioPlayer.resume();
                                  },
                                  onTap: (() async {
                                    performPlayAndPauseAction(index);
                                  }),
                                  audioPlayer: selectedIndex == index
                                      ? audioPlayer
                                      : pausePlayer,
                                  isPlaying: selectedIndex == index
                                      ? isPlaying
                                      : false,
                                  isBuffering: selectedIndex == index
                                      ? isBuffering
                                      : false,
                                  duration: selectedIndex == index
                                      ? duration
                                      : pauseDuration,
                                  position: selectedIndex == index
                                      ? position
                                      : pausePosition,
                                  index: index,
                                  listHydra: ringtonelist,
                                  ringtoneName: ringtonelist[index].name!,
                                  auidoId: ringtonelist[index].id!.toString(),
                                  file: ringtonelist[index].file!,
                                );
                                // : RingtonesCard(
                                //     onNavigate: () async {
                                //       await audioPlayer.pause();
                                //       // ignore: use_build_context_synchronously
                                //       Navigator.push(
                                //         context,
                                //         MaterialPageRoute(
                                //           builder: (context) =>
                                //               CustomAudioPlayer(
                                //             listHydra: ringtonelist,
                                //             index: index,
                                //             type: widget.itemType,
                                //           ),
                                //         ),
                                //       );
                                //     },
                                //     onChange: (value) async {
                                //       final myposition =
                                //           Duration(seconds: value.toInt());
                                //       await audioPlayer.seek(myposition);
                                //       await audioPlayer.resume();
                                //     },
                                //     onTap: (() async {
                                //       // if (isPlaying) {
                                //       // } else {}

                                //       setState(() {
                                //         selectedIndex = index;
                                //         position = Duration.zero;
                                //         isPlaying = false;
                                //       });
                                //       await audioPlayer.pause();
                                //       if (isPlaying) {
                                //         await audioPlayer.pause();
                                //       } else {
                                //         await audioPlayer.play(
                                //             ringtonelist[index].file!);
                                //       }
                                //     }),
                                //     audioPlayer: selectedIndex == index
                                //         ? audioPlayer
                                //         : pausePlayer,
                                //     isPlaying: selectedIndex == index
                                //         ? isPlaying
                                //         : false,
                                //     duration: selectedIndex == index
                                //         ? duration
                                //         : pauseDuration,
                                //     position: selectedIndex == index
                                //         ? position
                                //         : pausePosition,
                                //     index: index,
                                //     listHydra: ringtonelist,
                                //     ringtoneName: ringtonelist[index].name!,
                                //     auidoId:
                                //         ringtonelist[index].id!.toString(),
                                //     file: ringtonelist[index].file!,
                                //   );
                              },
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            _isNotification
                ? Expanded(
                    child: SmartRefresher(
                      enablePullUp: true,
                      controller: _notificationRefreshController,
                      onRefresh: () async {
                        print('>> SmartRefresher - onRefresh - Notifications');
                        final result =
                            await fetchNotifications(isRefresh: true);
                        if (result) {
                          _notificationRefreshController.refreshCompleted();
                        } else {
                          _notificationRefreshController.refreshFailed();
                        }
                      },
                      onLoading: () async {
                        print('>> SmartRefresher - onLoading - Notifications');
                        final result = await fetchNotifications();
                        if (result) {
                          _notificationRefreshController.loadComplete();
                        } else {
                          _notificationRefreshController.loadFailed();
                        }
                      },
                      header:
                          CustomHeader(builder: (context, mode) => Container()),
                      footer: CustomFooter(builder: (context, mode) {
                        print(
                            '>> CustomFooter - Notifications - _isNotificationDataLoad , _notificationTotalPage : $_isNotificationDataLoad , $_notificationTotalPage ');
                        return _isNotificationDataLoad &&
                                _notificationTotalPage != 0
                            ? const LoadingPage()
                            : const SizedBox();
                      }),
                      child: isLoading
                          ? const LoadingPage()
                          : ListView.builder(
                              itemCount: _notificationList.length,
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return selectedIndex == index
                                    ? RingtonesCard(
                                        onNavigate: () async {
                                          await audioPlayer.pause();
                                          // ignore: use_build_context_synchronously
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomAudioPlayer(
                                                listHydra: _notificationList,
                                                index: index,
                                                type: widget.itemType,
                                              ),
                                            ),
                                          );
                                        },
                                        onChange: (value) async {
                                          final myposition =
                                              Duration(seconds: value.toInt());
                                          await audioPlayer.seek(myposition);
                                          await audioPlayer.resume();
                                        },
                                        onTap: (() async {
                                          // if (isPlaying) {
                                          // } else {}

                                          setState(() {
                                            selectedIndex = index;
                                            position = Duration.zero;
                                          });

                                          if (isPlaying) {
                                            await audioPlayer.pause();
                                          } else {
                                            await audioPlayer.play(
                                                _notificationList[index].file!);
                                          }
                                        }),
                                        audioPlayer: selectedIndex == index
                                            ? audioPlayer
                                            : pausePlayer,
                                        isPlaying: selectedIndex == index
                                            ? isPlaying
                                            : false,
                                        duration: selectedIndex == index
                                            ? duration
                                            : pauseDuration,
                                        position: selectedIndex == index
                                            ? position
                                            : pausePosition,
                                        index: index,
                                        listHydra: _notificationList,
                                        ringtoneName:
                                            _notificationList[index].name!,
                                        auidoId: _notificationList[index]
                                            .id!
                                            .toString(),
                                        file: _notificationList[index].file!,
                                      )
                                    : RingtonesCard(
                                        onNavigate: () async {
                                          await audioPlayer.pause();
                                          // ignore: use_build_context_synchronously
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  CustomAudioPlayer(
                                                listHydra: _notificationList,
                                                index: index,
                                                type: widget.itemType,
                                              ),
                                            ),
                                          );
                                        },
                                        onChange: (value) async {
                                          final myposition =
                                              Duration(seconds: value.toInt());
                                          await audioPlayer.seek(myposition);
                                          await audioPlayer.resume();
                                        },
                                        onTap: (() async {
                                          // if (isPlaying) {
                                          // } else {}

                                          setState(() {
                                            selectedIndex = index;
                                            position = Duration.zero;
                                            isPlaying = false;
                                          });
                                          await audioPlayer.pause();
                                          if (isPlaying) {
                                            await audioPlayer.pause();
                                          } else {
                                            await audioPlayer.play(
                                                _notificationList[index].file!);
                                          }
                                        }),
                                        audioPlayer: selectedIndex == index
                                            ? audioPlayer
                                            : pausePlayer,
                                        isPlaying: selectedIndex == index
                                            ? isPlaying
                                            : false,
                                        duration: selectedIndex == index
                                            ? duration
                                            : pauseDuration,
                                        position: selectedIndex == index
                                            ? position
                                            : pausePosition,
                                        index: index,
                                        listHydra: _notificationList,
                                        ringtoneName:
                                            _notificationList[index].name!,
                                        auidoId: _notificationList[index]
                                            .id!
                                            .toString(),
                                        file: _notificationList[index].file!,
                                      );
                              },
                            ),
                    ),
                  )
                : const SizedBox.shrink(),
            isWallpaper
                ? Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: SmartRefresher(
                        enablePullUp: true,
                        controller: _wallpaperRefreshController,
                        onRefresh: () async {
                          final result = await fetchWallpaper(isRefresh: true);
                          if (result) {
                            _wallpaperRefreshController.refreshCompleted();
                          } else {
                            _wallpaperRefreshController.refreshFailed();
                          }
                        },
                        onLoading: () async {
                          print('>> SmartRefresher - onLoading - Wallapaper');
                          final result = await fetchWallpaper();
                          if (result) {
                            _wallpaperRefreshController.loadComplete();
                          } else {
                            _wallpaperRefreshController.loadFailed();
                          }
                        },
                        header: CustomHeader(
                            builder: (context, mode) => Container()),
                        footer: CustomFooter(
                            builder: (context, mode) =>
                                isWallPaperDataLoad && wallpaperTotalPage != 0
                                    ? const LoadingPage()
                                    : const SizedBox()),
                        child: isLoading
                            ? const LoadingPage()
                            : GridView.builder(
                                itemCount: wallpaperList.length,
                                controller: scrollController,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 3 / 6,
                                        crossAxisSpacing: 5,
                                        mainAxisSpacing: 5),
                                itemBuilder: (context, index) {
                                  return CategoryCard(
                                    id: wallpaperList[index].id.toString(),
                                    index: index,
                                    listHydra: wallpaperList,
                                    image: wallpaperList[index].file!,
                                    name: wallpaperList[index].name!,
                                  );
                                }),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> performPlayAndPauseAction(int index) async {
    {
      print(
          '>> performPlayAndPauseAction - selectedIndex , index : $selectedIndex , $index');
      bool isCurrentlySelectedIndex = (selectedIndex == index);

      if (selectedIndex != index && (isPlaying || isBuffering)) {
        await audioPlayer.stop();
        setState(() {
          isPlaying = false;
          isBuffering = false;
        });
      }

      setState(() {
        selectedIndex = index;
        position = Duration.zero;
      });

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
                  () => performPlayAndPauseAction(index));
            }),
          );
        } else {
          setState(() {
            isBuffering = true;
          });
          await audioPlayer.play(ringtonelist[index].file!);
        }
      }
    }
  }

  Padding buildTabsBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: (() {
              setState(() {
                isRingtone = true;
                _isNotification = false;
                isWallpaper = false;
              });
            }),
            child: Column(
              children: [
                Container(
                  height: 30,
                  alignment: Alignment.center,
                  width: 90,
                  decoration: BoxDecoration(
                    color: isRingtone
                        ? const Color(0xFF4e3d71)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Ringtones",
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 27,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6666),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "${ringtonelist.length}",
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: (() {
              setState(() {
                isRingtone = false;
                _isNotification = true;
                isWallpaper = false;
              });
            }),
            child: Column(
              children: [
                Container(
                  height: 30,
                  width: 90,
                  alignment: Alignment.center,
                  // width: MediaQuery.of(context).size.width * 0.25,
                  decoration: BoxDecoration(
                    color: _isNotification
                        ? const Color(0xFF4e3d71)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Notifications",
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 27,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6666),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "${_notificationList.length}",
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: (() {
              setState(() {
                isRingtone = false;
                _isNotification = false;
                isWallpaper = true;
              });
            }),
            child: Column(
              children: [
                Container(
                  height: 30,
                  width: 90,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isWallpaper
                        ? const Color(0xFF4e3d71)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Wallpapers",
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 27,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6666),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "${wallpaperList.length}",
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
