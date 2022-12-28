import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/ads_util/app_lifecycle_reactor.dart';
import 'package:deeze_app/ads_util/app_open_ad_manager.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/ad_helper.dart';
import 'package:deeze_app/models/search_model.dart';
import 'package:deeze_app/screens/categories/categories.dart';
import 'package:deeze_app/screens/custom_widgets/custom_drawer.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/search/search_screen.dart';
import 'package:deeze_app/screens/setting.dart';
import 'package:deeze_app/screens/tags/tags.dart';
import 'package:deeze_app/screens/web_view/show_web_page.dart';
import 'package:deeze_app/uitilities/constants.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:deeze_app/widgets/ringtone_category_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import 'package:rate_my_app/rate_my_app.dart';
import '../../bloc/deeze_bloc/Category_bloc/category_bloc.dart';
import '../../models/deeze_model.dart';
import '../../services/search_services.dart';
import '../../uitilities/end_points.dart';

import '../../widgets/audio_player.dart';
import '../../widgets/widgets.dart';

import '../wallpapers/wallpapers.dart';
import 'package:intl/intl.dart';

class Dashbaord extends StatefulWidget {
  final String type;

  const Dashbaord({Key? key, required this.type}) : super(key: key);

  @override
  State<Dashbaord> createState() => _DashbaordState();
}

class _DashbaordState extends State<Dashbaord> with WidgetsBindingObserver {
  final SearchServices _searchServices = SearchServices();

  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  bool isPlaying = false;
  bool _isBuffering = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;
  String _searchQuery = '';
  List<SearchModel> _searchResultList = [];
  Timer? _searchQueryTimer = null;
  bool _showSearchQueryProgressBar = false;
  BannerAd? _bannerAd;
  // late AppOpenAdManager _appOpenAdManager;
  // late AppLifecycleReactor _appLifecycleReactor;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // TODO: Load a banner ad
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
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isDataLoad = true;
        });
      }
    });
    addTrendingList();
    context.read<CategoryBloc>().add(LoadCategory());
    audioPlayer.onPlayerStateChanged.listen((state) {
      print(
          '>> audioPlayer.onPlayerStateChanged - state , mounted : ${state.name} , $mounted');

      if (state == PlayerState.PAUSED) {
        isPlaying = false;
      } else if (state == PlayerState.COMPLETED) {
        isPlaying = false;
        _isBuffering = false;
      }
      if (mounted) {
        setState(() {
          // isPlaying = state == PlayerState.PLAYING;
        });
      }
    });
    audioPlayer.onDurationChanged.listen((state) {
      _isBuffering = false;
      isPlaying = true;
      print(
          '>> audioPlayer.onDurationChanged - _isBuffering , isPlaying : $_isBuffering , $isPlaying ');

      setState(() {
        duration = state;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((state) {
      print(
          ">> dashboard - onAudioPositionChanged - position : ${state.inMicroseconds.toDouble()}");
      _isBuffering = false;
      isPlaying = true;
      setState(() {
        position = state;
      });
    });

    // _appOpenAdManager = AppOpenAdManager()..loadAd();
    // _appOpenAdManager = AppOpenAdManager();
    // _appOpenAdManager.loadAd();
    // _appLifecycleReactor =
    //     AppLifecycleReactor(appOpenAdManager: _appOpenAdManager);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('>> dashboard - didChangeAppLifecycleState - state : ${state.name}');
    // if (state == AppLifecycleState.resumed) {
    //   // print('>> dashboard - didChangeAppLifecycleState - profrm : ${state.name}');
    //   _appOpenAdManager.showAdIfAvailable();
    // }

    setState(() {});
  }

  addTrendingList() async {
    if (_searchServices.trendingSearchItems.isEmpty) {
      await _searchServices.trendingSearch();
      setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bannerAd?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    audioPlayer.dispose();
    isPlaying = false;
    PlayerState.STOPPED;
  }

  int page = 1;
  int? totalPage;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  ScrollController scrollController = ScrollController();
  bool isDataLoad = false;

  List<DeezeItemModel> hydraMember = [];

  Future<bool> fetchRingtone({bool isRefresh = false}) async {
    print('>> fetchRingtone()');
    if (isRefresh) {
      page = 1;
    } else {
      if (totalPage == 0) {
        _refreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppHpUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      // "enabled": "true",
      // "type":  "RINGTONE"
      "type": widget.type
    });
    try {
      if (isRefresh) setState(() => isLoading = true);
      print('>> fetchRingtone - url = ${uri.toString()}');
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
        if (isRefresh) {
          hydraMember = rawResponse;
        } else {
          hydraMember.addAll(rawResponse);
        }

        page++;
        totalPage = rawResponse.length;
        setState(() {
          isLoading = false;
          if (isDataLoad && totalPage == 0) {
            showMessage(context, message: 'No data available!');
          }
          isDataLoad = false;
        });
        return true;
      } else {
        return false;
      }
    } catch (ex, stack) {
      print('>> $ex');
      return false;
    }
  }

  final TextEditingController _typeAheadController = TextEditingController();
  bool ishow = false;
  int? selectedIndex;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    // print('>> dashboard - build()');
    double screenWidth = MediaQuery.of(context).size.width;
    return ishow
        ? WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
              resizeToAvoidBottomInset: false,
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
                  header: CustomHeader(builder: (context, mode) => Container()),
                  footer: CustomFooter(
                      builder: (context, mode) => isDataLoad && totalPage != 0
                          ? const LoadingPage()
                          : const SizedBox()),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 60),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 20),
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
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: 60,
                                    width: screenWidth,
                                    child: BlocConsumer<CategoryBloc,
                                        CategoryState>(
                                      listener: (context, state) {
                                        // TODO: implement listener
                                      },
                                      builder: (context, state) {
                                        if (state is CategoryInitial) {
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (state is LoadedCategory) {
                                          return Container(
                                            height: 50,
                                            margin:
                                                const EdgeInsets.only(left: 17),
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: 4,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 12),
                                                  child: RingtoneCategoryCard(
                                                    id: state
                                                        .categories![index].id!,
                                                    image: state
                                                        .categories![index]
                                                        .image,
                                                    name: state
                                                        .categories![index]
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
                                  const SizedBox(height: 20),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 17),
                                    child: Text(
                                      "Trending Search",
                                      style: GoogleFonts.archivo(
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  SizedBox(
                                    height: 33,
                                    width: screenWidth,
                                    child:
                                        buildTrendingSearchContainerForMainScreen(),
                                  ),
                                  const SizedBox(height: 30),
                                ]),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                controller: scrollController,
                                itemCount: hydraMember.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: selectedIndex == index
                                      ? RingtonesCard(
                                          auidoId:
                                              hydraMember[index].id!.toString(),
                                          onNavigate: () async {
                                            await audioPlayer.pause();
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomAudioPlayer(
                                                  listHydra: hydraMember,
                                                  index: index,
                                                  type: widget.type,
                                                ),
                                              ),
                                            );
                                          },
                                          onChange: (value) async {
                                            final myposition = Duration(
                                                seconds: value.toInt());
                                            await audioPlayer.seek(myposition);
                                            await audioPlayer.resume();
                                          },
                                          onTap: (() async {
                                            await activeRingtoneCardOnTapFunction(
                                                index);
                                          }),
                                          audioPlayer: selectedIndex == index
                                              ? audioPlayer
                                              : pausePlayer,
                                          isPlaying: selectedIndex == index
                                              ? isPlaying
                                              : false,
                                          isBuffering: selectedIndex == index
                                              ? _isBuffering
                                              : false,
                                          duration: selectedIndex == index
                                              ? duration
                                              : pauseDuration,
                                          position: selectedIndex == index
                                              ? position
                                              : pausePosition,
                                          index: index,
                                          listHydra: hydraMember,
                                          ringtoneName:
                                              hydraMember[index].name!,
                                          file: hydraMember[index].file!,
                                        )
                                      : RingtonesCard(
                                          auidoId:
                                              hydraMember[index].id!.toString(),
                                          onNavigate: () async {
                                            await audioPlayer.pause();
                                            // ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CustomAudioPlayer(
                                                  listHydra: hydraMember,
                                                  index: index - 1,
                                                  type: widget.type,
                                                ),
                                              ),
                                            );
                                          },
                                          onChange: (value) async {
                                            final myposition = Duration(
                                                seconds: value.toInt());
                                            await audioPlayer.seek(myposition);
                                            await audioPlayer.resume();
                                          },
                                          onTap: (() async {
                                            await nonActiveRingtoneCardFunction(
                                                index);
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
                                          listHydra: hydraMember,
                                          ringtoneName:
                                              hydraMember[index].name!,
                                          file: hydraMember[index].file!,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              height: 46,
                              // height: 30,
                              width: MediaQuery.of(context).size.width,
                              child: TextFormField(
                                controller: _typeAheadController,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                // onChanged: (data) => setState(() {}),
                                onChanged: (newValue) {
                                  if (_searchQueryTimer != null) {
                                    print('>> _searchQueryTimer is not null');
                                    _searchQueryTimer!.cancel();
                                  }

                                  _searchQueryTimer =
                                      Timer(Duration(milliseconds: 2000), () {
                                    DateTime now = DateTime.now();
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd – HH:mm:ss')
                                            .format(now);
                                    print(
                                        '>> ${DateTime.now()} performSearch - newValue : $newValue');
                                    performSearchRintone();
                                  });
                                  // performSearchRintone();
                                },
                                onFieldSubmitted: (val) {
                                  FocusScope.of(context).unfocus();
                                  if (_typeAheadController.text.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                                searchText:
                                                    _typeAheadController.text,
                                                itemType: widget.type,
                                              )),
                                    );
                                  }
                                  _typeAheadController.clear();
                                  ishow = false;
                                },
                                decoration: InputDecoration(
                                  hintText: "",
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
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
                                        topRight: Radius.circular(7),
                                        topLeft: Radius.circular(7)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF5d318c), width: 0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(7),
                                        topLeft: Radius.circular(7)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF5d318c), width: 0.0),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      if (_typeAheadController.text.isEmpty) {
                                        ishow = false;
                                      } else {
                                        _typeAheadController.clear();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SearchScreen(
                                                    searchText:
                                                        _typeAheadController
                                                            .text,
                                                    itemType: widget.type,
                                                  )),
                                        );
                                        ishow = false;
                                      }
                                      _typeAheadController.clear();
                                      setState(() {});
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 14,
                                      ),
                                      child: AppImageAsset(
                                        image: 'assets/search.svg',
                                        color: Colors.black,
                                        // color: Colors.orange,
                                      ),
                                      // child: Icon(Icons.search),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            buildSearchResultContainer(),
                            // buildTrendingSearchContainer(context),
                          ],
                        ),
                      ],
                    ),
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
                child: AppBar(
                  backgroundColor: const Color(0xFF4d047d),
                  elevation: 0,
                  centerTitle: true,
                  leading: Builder(
                    builder: (ctx) {
                      return GestureDetector(
                        onTap: () async {
                          await audioPlayer.pause();
                          Scaffold.of(ctx).openDrawer();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: AppImageAsset(image: 'assets/menu.svg'),
                        ),
                      );
                    },
                  ),
                  title: ishow
                      ? SizedBox(
                          height: 43,
                          width: MediaQuery.of(context).size.width,
                          child: TypeAheadField<SearchModel?>(
                              suggestionsBoxDecoration:
                                  const SuggestionsBoxDecoration(
                                      color: Color(0xFF4d047d)),
                              suggestionsCallback: (value) {
                                return performSearchRintone();
                              },
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
                                    onTap: () => setState(() => ishow = false),
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: const AppImageAsset(
                                        image: 'assets/search.svg',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (context, SearchModel? suggestion) {
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
                                        borderRadius: BorderRadius.circular(10),
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
                                                    fontStyle: FontStyle.normal,
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                const AppImageAsset(
                                                    image:
                                                        'assets/favourite_fill.svg',
                                                    height: 30),
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
                                  (SearchModel? suggestion) {},
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
                          buildAppBarTitle,
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
                            onTap: () {
                              print('>> search - onTap');
                              setState(() => ishow = true);
                            },
                            // onTap: () {
                            //   Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (context) => SearchScreen(
                            //               searchText: _typeAheadController.text,
                            //             )),
                            //   );
                            // },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: AppImageAsset(image: 'assets/search.svg'),
                            ),
                          ),
                  ],
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
                    print('>> dashboard - SmartRefresher - onRefresh');
                    final result = await fetchRingtone(isRefresh: true);
                    if (result) {
                      _refreshController.refreshCompleted();
                    } else {
                      _refreshController.refreshFailed();
                    }
                  },
                  onLoading: () async {
                    print('>> dashboard - SmartRefresher - onLoading');
                    final result = await fetchRingtone();
                    if (result) {
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadFailed();
                    }
                  },
                  header: CustomHeader(builder: (context, mode) => Container()),
                  footer: CustomFooter(builder: (context, mode) {
                    print(
                        '>> CustomFooter - isDataLoad , totalPage : $isDataLoad , $totalPage');
                    return isDataLoad && totalPage != 0
                        ? const LoadingPage()
                        : const SizedBox();
                  }),
                  child: isLoading
                      ? const LoadingPage()
                      : ListView.builder(
                          itemCount: hydraMember.length + 1,
                          scrollDirection: Axis.vertical,
                          controller: scrollController,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return SizedBox(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      wordSpacing: 0.16,
                                                      fontWeight:
                                                          FontWeight.w400,
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
                                        child: BlocConsumer<CategoryBloc,
                                            CategoryState>(
                                          listener: (context, state) {
                                            // TODO: implement listener
                                          },
                                          builder: (context, state) {
                                            if (state is CategoryInitial) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            }
                                            if (state is LoadedCategory) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 17),
                                                child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: 4,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 12),
                                                      child:
                                                          RingtoneCategoryCard(
                                                        id: state
                                                            .categories![index]
                                                            .id!,
                                                        image: state
                                                            .categories![index]
                                                            .image,
                                                        name: state
                                                            .categories![index]
                                                            .name,
                                                      ),
                                                    );
                                                  },
                                                ),
                                              );
                                            }
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
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
                                          "Trending search",
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
                                        child:
                                            buildTrendingSearchContainerForMainScreen(),
                                      ),
                                      SizedBox(height: 5),
                                      if (_bannerAd != null)
                                        Align(
                                          alignment: Alignment.topCenter,
                                          child: Container(
                                            width: _bannerAd!.size.width
                                                .toDouble(),
                                            height: _bannerAd!.size.height
                                                .toDouble(),
                                            child: AdWidget(ad: _bannerAd!),
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                    ]),
                              );
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              // child: selectedIndex == index
                              //     ? buildActiveRingtoneCard(index - 1, context)
                              //     : buildNonActiveRingtoneCard(
                              //         index - 1, context),
                              child:
                                  buildActiveRingtoneCard(index - 1, context),
                            );
                          },
                        ),
                ),
              ),
              drawer: CustomDrawer(),
            ),
          );
  }

  RingtonesCard buildActiveRingtoneCard(int index, BuildContext context) {
    return RingtonesCard(
      auidoId: hydraMember[index].id!.toString(),
      onNavigate: () async {
        print('>> dashboard - onNavigate - activeCard - index = $index');
        await audioPlayer.pause();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomAudioPlayer(
              listHydra: hydraMember.sublist(index),
              // index: index,
              index: 0,
              type: widget.type,
            ),
          ),
        );
      },
      onChange: (value) async {
        final myposition = Duration(microseconds: value.toInt());
        await audioPlayer.seek(myposition);
        await audioPlayer.resume();
      },
      onTap: (() async {
        // if (isPlaying) {
        // } else {}
        await activeRingtoneCardOnTapFunction(index);
      }),
      audioPlayer: selectedIndex == index ? audioPlayer : pausePlayer,
      isPlaying: selectedIndex == index ? isPlaying : false,
      isBuffering: selectedIndex == index ? _isBuffering : false,
      duration: selectedIndex == index ? duration : pauseDuration,
      position: selectedIndex == index ? position : pausePosition,
      index: index,
      listHydra: hydraMember,
      ringtoneName: hydraMember[index].name!,
      file: hydraMember[index].file!,
    );
  }

  RingtonesCard buildNonActiveRingtoneCard(int index, BuildContext context) {
    return RingtonesCard(
      auidoId: hydraMember[index].id!.toString(),
      onNavigate: () async {
        print('>> dashboard - onNavigate - nonActiveCard - index = $index');
        await audioPlayer.pause();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomAudioPlayer(
              listHydra: hydraMember,
              index: index,
              type: widget.type,
            ),
          ),
        );
      },
      onChange: (value) async {
        final myposition = Duration(microseconds: value.toInt());
        await audioPlayer.seek(myposition);
        await audioPlayer.resume();
      },
      onTap: (() async {
        // if (isPlaying) {
        // } else {}
        await nonActiveRingtoneCardFunction(index);
      }),
      audioPlayer: selectedIndex == index ? audioPlayer : pausePlayer,
      isPlaying: selectedIndex == index ? isPlaying : false,
      isBuffering: selectedIndex == index ? _isBuffering : false,
      duration: selectedIndex == index ? duration : pauseDuration,
      position: selectedIndex == index ? position : pausePosition,
      index: index,
      listHydra: hydraMember,
      ringtoneName: hydraMember[index].name!,
      file: hydraMember[index].file!,
    );
  }

  Future<void> nonActiveRingtoneCardFunction(int index) async {
    print('>> nonActiveRingtoneCardFunction - index = $index');
    // if (isPlaying) {
    // } else {}
    setState(() {
      selectedIndex = index;
      position = Duration.zero;
      isPlaying = false;
      _isBuffering = true;
    });
    await audioPlayer.pause();
    if (isPlaying) {
      await audioPlayer.pause();
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
                () => nonActiveRingtoneCardFunction(index));
          }),
        );
      } else {
        setState(() {
          _isBuffering = true;
        });
        await audioPlayer.play(hydraMember[index].file!);
      }
      // _isBuffering = false;

      // Uri downloadedFileUri = await audioPlayer.audioCache.load(
      //     hydraMember[index].file!);
      //   await audioPlayer.play( DeviceFileSource(downloadedFileUri.toFilePath()));

    }
  }

  Future<void> activeRingtoneCardOnTapFunction(int index) async {
    print(
        '>> activeRingtoneCardOnTapFunction - index , selectedIndex = $index , $selectedIndex');

    if (selectedIndex != index) {
      await audioPlayer.pause();
      isPlaying = false;
      _isBuffering = false;
    }
    setState(() {
      selectedIndex = index;
      // position = Duration.zero;
    });

    if (isPlaying || _isBuffering) {
      await audioPlayer.pause();
      setState(() {
        isPlaying = false;
        _isBuffering = false;
      });
    }
    // else if (audioPlayer.state == PlayerState.PAUSED) {
    //   audioPlayer.resume();
    //   setState(() {
    //     _isBuffering = false;
    //     isPlaying = true;
    //   });
    // }
    else {
      bool hasInternet = await InternetConnectionChecker().hasConnection;
      print('>> hasInternet : $hasInternet');
      if (!await InternetConnectionChecker().hasConnection) {
        showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => InternetCheckerDialog(onRetryTap: () {
            Navigator.pop(ctx); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500),
                () => activeRingtoneCardOnTapFunction(index));
          }),
        );
      } else {
        setState(() {
          _isBuffering = true;
          position = Duration.zero;
        });
        // await audioPlayer.play(hydraMember[index].file!);
        await audioPlayer.play(hydraMember[index].file!);
      }
    }
  }

  Padding buildTrendingSearchContainerForMainScreen() {
    return Padding(
      padding: const EdgeInsets.only(left: 17),
      child: ListView.builder(
        itemCount: _searchServices.trendingSearchItems.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _searchServices.trendingSearchItems.isEmpty
                ? const LoadingPage()
                : InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchScreen(
                                  searchText: _searchServices
                                      .trendingSearchItems[index],
                                  itemType: widget.type,
                                )),
                      );
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.2),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          _searchServices.trendingSearchItems[index],
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }

  Container buildTrendingSearchContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(30).copyWith(top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trending search',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: List.generate(
              _searchServices.trendingSearchItems.length,
              (index) => Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0XFFE1E1E1)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _searchServices.trendingSearchItems[index],
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get buildAppBarTitle {
    if (widget.type == ItemType.RINGTONE.name)
      return "Ringtones";
    else if (widget.type == ItemType.NOTIFICATION.name)
      return "Notifications";
    else
      return "Wallpapers";
  }

  Future<List<SearchModel>> performSearchRintone() async {
    String searchStr = _typeAheadController.text.trim();
    if (searchStr.isNotEmpty) {
      setState(() {
        _showSearchQueryProgressBar = true;
      });

      if (!await InternetConnectionChecker().hasConnection) {
        showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => InternetCheckerDialog(
            onRetryTap: () {
              Navigator.pop(context); // Hide Internet Message Dialog
              Timer(Duration(milliseconds: 500), () => performSearchRintone());
            },
          ),
        );
        setState(() {
          _showSearchQueryProgressBar = false;
        });
        return [];
      }

      _searchResultList = await _searchServices.searchRingtone(
          query: searchStr, type: widget.type);
    } else {
      _searchResultList = [];
    }
    _searchQuery = searchStr;
    setState(() {
      _showSearchQueryProgressBar = false;
    });
    return _searchResultList;
  }

  // FutureBuilder<List<SearchModel>> buildSearchResultContainer() {
  //   return FutureBuilder<List<SearchModel>>(
  //       future:
  //           _searchServices.searchRingtone(_typeAheadController.text.trim()),
  //       builder:
  //           (BuildContext context, AsyncSnapshot<List<SearchModel>> snapshot) {
  //         print('>> FutureBuilder<List<SearchModel>> - builder');
  //         if (snapshot.hasError) {
  //           return Container(
  //               color: Colors.white,
  //               alignment: Alignment.centerLeft,
  //               margin: const EdgeInsets.symmetric(horizontal: 16),
  //               padding:
  //                   const EdgeInsets.symmetric(vertical: 10).copyWith(left: 30),
  //               child: const Text(
  //                 "Something went wrong",
  //                 style: TextStyle(color: Color(0xFF5d318c)),
  //               ));
  //         }
  //         if (snapshot.connectionState == ConnectionState.done) {
  //           return Container(
  //             color: Colors.white,
  //             margin: const EdgeInsets.symmetric(horizontal: 16),
  //             child: ListView.builder(
  //               shrinkWrap: true,
  //               padding: EdgeInsets.zero,
  //               itemCount:
  //                   snapshot.data!.length > 4 ? 4 : snapshot.data!.length,
  //               itemBuilder: (context, index) => GestureDetector(
  //                 onTap: (() {
  //                   _typeAheadController.clear();
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => SearchScreen(
  //                               searchText: snapshot.data![index].name!,
  //                             )),
  //                   );
  //                   ishow = false;
  //                 }),
  //                 child: Padding(
  //                     padding:
  //                         const EdgeInsets.only(left: 30, top: 10, bottom: 10),
  //                     child: Text(
  //                       "${snapshot.data![index].name}",
  //                       style: GoogleFonts.archivo(
  //                         fontStyle: FontStyle.normal,
  //                         color: const Color(0xFF5d318c),
  //                         fontSize: 18,
  //                         fontWeight: FontWeight.w500,
  //                       ),
  //                     )),
  //               ),
  //             ),
  //           );
  //         } else {
  //           return Container();
  //         }
  //       });
  // }

  Widget buildSearchResultContainer() {
    if (_showSearchQueryProgressBar) {
      return Container(
          // color: Colors.white,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(child: RefreshProgressIndicator()));
    } else if (_searchResultList == null) {
      return Container(
          // color: Colors.white,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
          ),
          // margin: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 10).copyWith(left: 30),
          child: const Text(
            "Something went wrong",
            style: TextStyle(color: Color(0xFF5d318c)),
          ));
    } else if (_searchResultList.length > 0) {
      return Container(
        // color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount:
              _searchResultList.length > 4 ? 4 : _searchResultList.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: (() {
              _typeAheadController.clear();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SearchScreen(
                        searchText: _searchResultList[index].name!,
                        itemType: widget.type)),
              );
              ishow = false;
            }),
            child: Padding(
                padding: const EdgeInsets.only(left: 30, top: 10, bottom: 10),
                child: Text(
                  "${_searchResultList[index].name}",
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0xFF5d318c),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
        ),
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );
    }
  }

  Future<bool> _onWillPop() async {
    ishow
        ? setState(() => ishow = false)
        : await showDialog(
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
          );
    return false;
  }
}
