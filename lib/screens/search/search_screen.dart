import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
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
  const SearchScreen({Key? key, required this.searchText}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchServices _searchServices = SearchServices();
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  int? selectedIndex;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    liseten();
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

  void liseten() async {
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
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

  final TextEditingController _typeAheadController = TextEditingController();
  int ringtonePage = 1;
  late int ringtoneTotalPage;
  final RefreshController _ringtoneRefreshController =
      RefreshController(initialRefresh: true);
  bool isWallpaper = false;
  bool isNotification = false;
  bool isRingtone = true;
  List<HydraMember> ringtonelist = [];
  Future<bool> fetchRingtone({bool isRefresh = false}) async {
    if (isRefresh) {
      ringtonePage = 1;
    } else {
      if (ringtonePage >= ringtoneTotalPage) {
        _ringtoneRefreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$ringtonePage",
      "itemsPerPage": "10",
      "enabled": "true",
      "name": widget.searchText,
      "type": "RINGTONE"
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeFromJson(response.body);
        if (isRefresh) {
          ringtonelist = rawResponse.hydraMember!;
        } else {
          ringtonelist.addAll(rawResponse.hydraMember!);
        }

        ringtonePage++;
        ringtoneTotalPage = rawResponse.hydraTotalItems!;
        setState(() {});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
///////////////////////

  int wallpaperPage = 1;
  late int wallpaperTotalPage;
  final RefreshController _wallpaperRefreshController =
      RefreshController(initialRefresh: true);

  List<HydraMember> wallpaperList = [];
  Future<bool> fetchWallpaper({bool isRefresh = false}) async {
    if (isRefresh) {
      wallpaperPage = 1;
    } else {
      if (wallpaperPage >= wallpaperTotalPage) {
        _wallpaperRefreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$wallpaperPage",
      "itemsPerPage": "10",
      "enabled": "true",
      "name": widget.searchText,
      "type": "WALLPAPER"
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeFromJson(response.body);
        if (isRefresh) {
          wallpaperList = rawResponse.hydraMember!;
        } else {
          wallpaperList.addAll(rawResponse.hydraMember!);
        }

        wallpaperPage++;
        wallpaperTotalPage = rawResponse.hydraTotalItems!;
        setState(() {});
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
        preferredSize: Size(0, 60),
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF4d047d),
              elevation: 0,
              centerTitle: true,
              title: SizedBox(
                height: 43,
                width: MediaQuery.of(context).size.width,
                child: TypeAheadFormField<HydraMember?>(
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
                        focusedBorder: const OutlineInputBorder(
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
                        // suffixIcon: GestureDetector(
                        //   onTap: (() {
                        //     setState(() {
                        //       ishow = false;
                        //     });
                        //   }),
                        //   child: const Icon(
                        //     Icons.clear,
                        //     color: Color(0xFF5d318c),
                        //   ),
                        // ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF5d318c),
                        ),
                      ),
                    ),
                    itemBuilder: (context, HydraMember? suggestion) {
                      final ringtone = suggestion!;
                      return GestureDetector(
                        onTap: (() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchScreen(
                                searchText: _typeAheadController.text,
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
                                color: Color(0xFF5d318c),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      );
                    },
                    onSuggestionSelected: (HydraMember? suggestion) {},
                    noItemsFoundBuilder: (context) => Center(
                          child: Text(
                            "No Found",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Color(0xFF5d318c),
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
                            color: Color(0xFF5d318c),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }),
              )),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (() {
                      setState(() {
                        isRingtone = true;
                        isNotification = false;
                        isWallpaper = false;
                      });
                    }),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: isRingtone
                                ? Color(0xFF5d318c)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Ringtone",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6666),
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
                        isNotification = true;
                        isWallpaper = false;
                      });
                    }),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: isNotification
                                ? Color(0xFF5d318c)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Notifications",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6666),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "0",
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
                        isNotification = false;
                        isWallpaper = true;
                      });
                    }),
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                            color: isWallpaper
                                ? Color(0xFF5d318c)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "Wallpapers",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: Color(0xFFFF6666),
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
            ),
            const SizedBox(
              height: 50,
            ),
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
                          final result = await fetchWallpaper();
                          if (result) {
                            _wallpaperRefreshController.loadComplete();
                          } else {
                            _wallpaperRefreshController.loadFailed();
                          }
                        },
                        child: GridView.builder(
                            itemCount: wallpaperList.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 3 / 6,
                                    crossAxisSpacing: 5,
                                    mainAxisSpacing: 5),
                            itemBuilder: (context, index) {
                              return CategoryCard(
                                index: index,
                                listHydra: wallpaperList,
                                image: wallpaperList[index].file!,
                                name: wallpaperList[index].name!,
                              );
                            }),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
            isRingtone
                ? Expanded(
                    child: SmartRefresher(
                      enablePullUp: true,
                      controller: _ringtoneRefreshController,
                      onRefresh: () async {
                        final result = await fetchRingtone(isRefresh: true);
                        if (result) {
                          _ringtoneRefreshController.refreshCompleted();
                        } else {
                          _ringtoneRefreshController.refreshFailed();
                        }
                      },
                      onLoading: () async {
                        final result = await fetchRingtone();
                        if (result) {
                          _ringtoneRefreshController.loadComplete();
                        } else {
                          _ringtoneRefreshController.loadFailed();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                          itemCount: ringtonelist.length,
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
                                            listHydra: ringtonelist,
                                            index: index,
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
                                        await audioPlayer
                                            .play(ringtonelist[index].file!);
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
                                    listHydra: ringtonelist,
                                    ringtoneName: ringtonelist[index].name!,
                                    file: ringtonelist[index].file!,
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
                                            listHydra: ringtonelist,
                                            index: index,
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
                                        await audioPlayer
                                            .play(ringtonelist[index].file!);
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
                                    listHydra: ringtonelist,
                                    ringtoneName: ringtonelist[index].name!,
                                    file: ringtonelist[index].file!,
                                  );
                          },
                        ),
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
