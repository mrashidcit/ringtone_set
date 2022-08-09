import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/screens/categories/categories.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/search/search_screen.dart';
import 'package:deeze_app/screens/tags/tags.dart';
import 'package:deeze_app/widgets/ringtone_category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import '../../bloc/deeze_bloc/Category_bloc/category_bloc.dart';
import '../../models/deeze_model.dart';
import '../../services/search_services.dart';
import '../../uitilities/end_points.dart';

import '../../widgets/audio_player.dart';
import '../../widgets/widgets.dart';

import '../wallpapers/wallpapers.dart';

class Dashbaord extends StatefulWidget {
  final String type;

  const Dashbaord({Key? key, required this.type}) : super(key: key);

  @override
  State<Dashbaord> createState() => _DashbaordState();
}

class _DashbaordState extends State<Dashbaord> {
  final SearchServices _searchServices = SearchServices();

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
    context.read<CategoryBloc>().add(LoadCategory());
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

  int page = 1;
  late int totalPage;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<HydraMember> hydraMember = [];

  Future<bool> fetchRingtone({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
    } else {
      if (page >= totalPage) {
        _refreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      "enabled": "true",
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
        var rawResponse = deezeFromJson(response.body);
        if (isRefresh) {
          hydraMember = rawResponse.hydraMember!;
        } else {
          hydraMember.addAll(rawResponse.hydraMember!);
        }

        page++;
        totalPage = rawResponse.hydraTotalItems!;
        setState(() {});
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  final TextEditingController _typeAheadController = TextEditingController();
  bool ishow = false;
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ishow
        ? WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size(0, 60),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xFF4d047d),
                    elevation: 0,
                    centerTitle: true,
                    title: ishow
                        ? SizedBox(
                            height: 43,
                            width: MediaQuery.of(context).size.width,
                            child: TypeAheadFormField<HydraMember?>(
                                suggestionsBoxVerticalOffset: 0,
                                suggestionsBoxDecoration:
                                    const SuggestionsBoxDecoration(
                                        color: Colors.white),
                                suggestionsCallback: _searchServices.search,
                                debounceDuration:
                                    const Duration(milliseconds: 500),
                                // hideSuggestionsOnKeyboardHide: false,
                                textFieldConfiguration: TextFieldConfiguration(
                                  controller: _typeAheadController,
                                  decoration: InputDecoration(
                                    hintText: "",
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF5d318c),
                                      fontSize: 12,
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 20,
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(7),
                                          topRight: Radius.circular(7)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF5d318c), width: 0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF5d318c), width: 0.0),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: (() {
                                        setState(() {
                                          ishow = false;
                                        });
                                      }),
                                      child: Image.asset(
                                          "assets/search_field.png"),
                                    ),
                                  ),
                                ),
                                itemBuilder:
                                    (context, HydraMember? suggestion) {
                                  final ringtone = suggestion!;
                                  return GestureDetector(
                                    onTap: (() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                            searchText:
                                                _typeAheadController.text,
                                          ),
                                        ),
                                      );
                                    }),
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30, top: 10),
                                        child: Text(
                                          "${ringtone.name}",
                                          style: GoogleFonts.archivo(
                                            fontStyle: FontStyle.normal,
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )),
                                  );
                                },
                                onSuggestionSelected:
                                    (HydraMember? suggestion) {},
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
                          )
                        : Text(
                            "Ringtones",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              wordSpacing: 0.34,
                            ),
                          ),
                    actions: [
                      ishow
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: (() {
                                setState(() {
                                  ishow = true;
                                });
                              }),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Image.asset("assets/search.png"),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              backgroundColor: const Color(0xFF4d047d),
              body: Container(
                height: MediaQuery.of(context).size.height,
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
                child: SmartRefresher(
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: () async {
                    final result = await fetchRingtone(isRefresh: true);
                    if (result) {
                      _refreshController.refreshCompleted();
                    } else {
                      _refreshController.refreshFailed();
                    }
                  },
                  onLoading: () async {
                    final result = await fetchRingtone();
                    if (result) {
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadFailed();
                    }
                  },
                  child: ListView.builder(
                    itemCount: hydraMember.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Categories",
                                        style: GoogleFonts.archivo(
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                          fontSize: 12,
                                          wordSpacing: 0.19,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (() {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Categories(
                                                        isRingtone: true,
                                                      )));
                                        }),
                                        child: Row(
                                          children: [
                                            Text(
                                              "View All",
                                              style: GoogleFonts.archivo(
                                                fontStyle: FontStyle.normal,
                                                color: Colors.white,
                                                fontSize: 10,
                                                wordSpacing: 0.16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 60,
                                  width: screenWidth,
                                  child:
                                      BlocConsumer<CategoryBloc, CategoryState>(
                                    listener: (context, state) {
                                      // TODO: implement listener
                                    },
                                    builder: (context, state) {
                                      if (state is CategoryInitial) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (state is LoadedCategory) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 17),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 4,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 12),
                                                child: RingtoneCategoryCard(
                                                  id: state.categories!
                                                      .hydraMember![index].id!,
                                                  image: state
                                                      .categories
                                                      ?.hydraMember?[index]
                                                      .image,
                                                  name: state
                                                      .categories
                                                      ?.hydraMember?[index]
                                                      .name,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17),
                                  child: Text(
                                    "Popular",
                                    style: GoogleFonts.archivo(
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Tags(),
                                const SizedBox(
                                  height: 30,
                                ),
                              ]),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: selectedIndex == index
                            ? RingtonesCard(
                                onNavigate: () async {
                                  await audioPlayer.pause();
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomAudioPlayer(
                                        listHydra: hydraMember,
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
                                        .play(hydraMember[index].file!);
                                  }
                                }),
                                audioPlayer: selectedIndex == index
                                    ? audioPlayer
                                    : pausePlayer,
                                isPlaying:
                                    selectedIndex == index ? isPlaying : false,
                                duration: selectedIndex == index
                                    ? duration
                                    : pauseDuration,
                                position: selectedIndex == index
                                    ? position
                                    : pausePosition,
                                index: index,
                                listHydra: hydraMember,
                                ringtoneName: hydraMember[index].name!,
                                file: hydraMember[index].file!,
                              )
                            : RingtonesCard(
                                onNavigate: () async {
                                  await audioPlayer.pause();
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomAudioPlayer(
                                        listHydra: hydraMember,
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
                                        .play(hydraMember[index].file!);
                                  }
                                }),
                                audioPlayer: selectedIndex == index
                                    ? audioPlayer
                                    : pausePlayer,
                                isPlaying:
                                    selectedIndex == index ? isPlaying : false,
                                duration: selectedIndex == index
                                    ? duration
                                    : pauseDuration,
                                position: selectedIndex == index
                                    ? position
                                    : pausePosition,
                                index: index,
                                listHydra: hydraMember,
                                ringtoneName: hydraMember[index].name!,
                                file: hydraMember[index].file!,
                              ),
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size(0, 60),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppBar(
                    backgroundColor: const Color(0xFF4d047d),
                    elevation: 0,
                    centerTitle: true,
                    leading: Builder(
                      builder: (ctx) {
                        return GestureDetector(
                            onTap: (() async {
                              await audioPlayer.pause();
                              Scaffold.of(ctx).openDrawer();
                            }),
                            child: Image.asset("assets/menu.png"));
                      },
                    ),
                    title: ishow
                        ? SizedBox(
                            height: 43,
                            width: MediaQuery.of(context).size.width,
                            child: TypeAheadField<HydraMember?>(
                                suggestionsBoxDecoration:
                                    const SuggestionsBoxDecoration(
                                        color: Color(0xFF4d047d)),
                                suggestionsCallback:
                                    _searchServices.searchRingtone,
                                debounceDuration:
                                    const Duration(milliseconds: 500),
                                // hideSuggestionsOnKeyboardHide: false,
                                textFieldConfiguration: TextFieldConfiguration(
                                  decoration: InputDecoration(
                                    hintText: "",
                                    hintStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    fillColor: const Color(0xFF5d318c),
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: 20,
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF5d318c), width: 0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF5d318c), width: 0.0),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: (() {
                                        setState(() {
                                          ishow = false;
                                        });
                                      }),
                                      child: Image.asset(
                                          "assets/search_field.png"),
                                    ),
                                  ),
                                ),
                                itemBuilder:
                                    (context, HydraMember? suggestion) {
                                  final ringtone = suggestion!;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Container(
                                        height: 65,
                                        width: screenWidth,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xFF279A88),
                                                Color(0xFF737B64),
                                                Color(0xFF4F4C7E),
                                                Color(0xFF4F4C7E),
                                              ]),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    height: 35,
                                                    width: 35,
                                                    alignment: Alignment.center,
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Color(0xFF798975),
                                                    ),
                                                    child: const Icon(
                                                      Icons.play_arrow_sharp,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text(
                                                    ringtone.name!,
                                                    style: GoogleFonts.archivo(
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  Image.asset(
                                                    "assets/heart.png",
                                                    height: 30,
                                                  ),
                                                  Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.arrow_downward,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      Text(
                                                        "23k",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )),
                                  );
                                },
                                onSuggestionSelected:
                                    (HydraMember? suggestion) {},
                                noItemsFoundBuilder: (context) => const Center(
                                      child: Text(
                                        "No Found",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Poppins-Regular',
                                        ),
                                      ),
                                    ),
                                errorBuilder: (BuildContext context, error) {
                                  return const Center(
                                    child: Text(
                                      "Please enter ",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins-Regular',
                                      ),
                                    ),
                                  );
                                }),
                          )
                        : Text(
                            "Ringtones",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              wordSpacing: 0.34,
                            ),
                          ),
                    actions: [
                      ishow
                          ? const SizedBox.shrink()
                          : GestureDetector(
                              onTap: (() {
                                setState(() {
                                  ishow = true;
                                });
                              }),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: Image.asset("assets/search.png"),
                              ),
                            )
                    ],
                  ),
                ),
              ),
              backgroundColor: const Color(0xFF4d047d),
              body: Container(
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Color(0xFF17131F),
                        Color(0xFF17131F),
                        Color(0xFF17131F),
                        Color(0xFF17131F),
                        Color(0xFF17131F),
                        Color(0xFF17131F),
                        Color(0xFF17131F),
                      ]),
                ),
                child: SmartRefresher(
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: () async {
                    final result = await fetchRingtone(isRefresh: true);
                    if (result) {
                      _refreshController.refreshCompleted();
                    } else {
                      _refreshController.refreshFailed();
                    }
                  },
                  onLoading: () async {
                    final result = await fetchRingtone();
                    if (result) {
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadFailed();
                    }
                  },
                  child: ListView.builder(
                    itemCount: hydraMember.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Categories",
                                        style: GoogleFonts.archivo(
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                          fontSize: 12,
                                          wordSpacing: 0.19,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: (() {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Categories(
                                                        isRingtone: true,
                                                      )));
                                        }),
                                        child: Row(
                                          children: [
                                            Text(
                                              "View All",
                                              style: GoogleFonts.archivo(
                                                fontStyle: FontStyle.normal,
                                                color: Colors.white,
                                                fontSize: 10,
                                                wordSpacing: 0.16,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            const Icon(
                                              Icons.arrow_forward,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 60,
                                  width: screenWidth,
                                  child:
                                      BlocConsumer<CategoryBloc, CategoryState>(
                                    listener: (context, state) {
                                      // TODO: implement listener
                                    },
                                    builder: (context, state) {
                                      if (state is CategoryInitial) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }
                                      if (state is LoadedCategory) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 17),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: 4,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 12),
                                                child: RingtoneCategoryCard(
                                                  id: state.categories!
                                                      .hydraMember![index].id!,
                                                  image: state
                                                      .categories
                                                      ?.hydraMember?[index]
                                                      .image,
                                                  name: state
                                                      .categories
                                                      ?.hydraMember?[index]
                                                      .name,
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 17),
                                  child: Text(
                                    "Popular",
                                    style: GoogleFonts.archivo(
                                      fontStyle: FontStyle.normal,
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                    height: 33,
                                    width: screenWidth,
                                    child: const Tags()),
                                const SizedBox(
                                  height: 30,
                                ),
                              ]),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: selectedIndex == index
                            ? RingtonesCard(
                                onNavigate: () async {
                                  await audioPlayer.pause();
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomAudioPlayer(
                                        listHydra: hydraMember,
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                                onChange: (value) async {
                                  final myposition =
                                      Duration(microseconds: value.toInt());
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
                                        .play(hydraMember[index].file!);
                                  }
                                }),
                                audioPlayer: selectedIndex == index
                                    ? audioPlayer
                                    : pausePlayer,
                                isPlaying:
                                    selectedIndex == index ? isPlaying : false,
                                duration: selectedIndex == index
                                    ? duration
                                    : pauseDuration,
                                position: selectedIndex == index
                                    ? position
                                    : pausePosition,
                                index: index,
                                listHydra: hydraMember,
                                ringtoneName: hydraMember[index].name!,
                                file: hydraMember[index].file!,
                              )
                            : RingtonesCard(
                                onNavigate: () async {
                                  await audioPlayer.pause();
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CustomAudioPlayer(
                                        listHydra: hydraMember,
                                        index: index,
                                      ),
                                    ),
                                  );
                                },
                                onChange: (value) async {
                                  final myposition =
                                      Duration(microseconds: value.toInt());
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
                                        .play(hydraMember[index].file!);
                                  }
                                }),
                                audioPlayer: selectedIndex == index
                                    ? audioPlayer
                                    : pausePlayer,
                                isPlaying:
                                    selectedIndex == index ? isPlaying : false,
                                duration: selectedIndex == index
                                    ? duration
                                    : pauseDuration,
                                position: selectedIndex == index
                                    ? position
                                    : pausePosition,
                                index: index,
                                listHydra: hydraMember,
                                ringtoneName: hydraMember[index].name!,
                                file: hydraMember[index].file!,
                              ),
                      );
                    },
                  ),
                ),
              ),
              drawer: Drawer(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF252030),
                    // gradient: const LinearGradient(colors: [
                    //   Color(0xFF252030),
                    // ]),
                    // borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        MyDrawerHeader(),
                        const SizedBox(
                          height: 40,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const Dashbaord(
                            //       type: "RINGTONE",
                            //     ),
                            //   ),
                            // );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Row(
                              children: [
                                Image.asset("assets/ringtone.png"),
                                const SizedBox(
                                  width: 26,
                                ),
                                Text(
                                  "Ringtones",
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontSize: 18,
                                    // fontWeight: FontWeight.w700,
                                    wordSpacing: -0.09,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop();
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const WallPapers(
                                  type: "WALLPAPER",
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Row(
                              children: [
                                Image.asset("assets/wallpapers.png"),
                                const SizedBox(
                                  width: 26,
                                ),
                                Text(
                                  "Wallpapers",
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontSize: 18,
                                    // fontWeight: FontWeight.w700,
                                    wordSpacing: -0.09,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Row(
                            children: [
                              SvgPicture.asset("assets/bell.svg"),
                              const SizedBox(
                                width: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Notifications",
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontSize: 18,
                                    // fontWeight: FontWeight.w700,
                                    wordSpacing: -0.09,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const FavouriteScreen(
                                        id: 9,
                                        type: 'Favourites',
                                      )),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Row(
                              children: [
                                Image.asset(
                                  "assets/heart.png",
                                  color: const Color(0xffA49FAD),
                                ),
                                const SizedBox(
                                  width: 29,
                                ),
                                Text(
                                  "Favourite",
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontSize: 18,
                                    // fontWeight: FontWeight.w700,
                                    wordSpacing: -0.09,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 37),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                "Help",
                                style: GoogleFonts.archivo(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 37),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.settings,
                                color: Color(0xffA49FAD),
                                size: 20,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                "Settings",
                                style: GoogleFonts.archivo(
                                  fontStyle: FontStyle.normal,
                                  color: const Color(0xffA49FAD),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 37),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.privacy_tip,
                                color: Color(0xffA49FAD),
                                size: 20,
                              ),
                              const SizedBox(
                                width: 25,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Privacy Policy",
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: const Color(0xffA49FAD),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Row(
                            children: [
                              Container(
                                height: 18,
                                width: 18,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Image.asset(
                                  "assets/fblogo.png",
                                  color: Colors.black,
                                ),
                              ),
                              // SizedBox(
                              //   height: 25,
                              //   width: 30,
                              //   child: Image.asset(
                              //     "assets/ringtone.png",
                              //     color: Colors.white,
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                "Join us on Facebook",
                                style: GoogleFonts.archivo(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                  audioPlayer.pause();
                  audioPlayer.dispose();
                },
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}
