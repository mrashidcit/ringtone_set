import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/db_services/favorite_database.dart';
import 'package:deeze_app/models/favorite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../../widgets/app_image_assets.dart';

import '../../widgets/category_card_gridview.dart';
import '../../widgets/drawer_header.dart';
import '../../widgets/ringtone_gridview_cart.dart';
import '../dashboard/dashboard.dart';
import '../wallpapers/wallpapers.dart';

class FavouriteScreen extends StatefulWidget {
  final String type;
  final int id;

  const FavouriteScreen({Key? key, required this.type, required this.id})
      : super(key: key);

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  bool isPlaying = false;
  int? selectedIndex;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;
  bool isDataLoad = false;
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getId();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isDataLoad = true;
        });
      }
    });

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

  int page = 1;
  int? totalPage;
  String? deviceId;
  getId() async {
    deviceId = await PlatformDeviceId.getDeviceId;
    setState(() {});
  }

  Stream<List<Favorite>> refreshPost() {
    return FavoriteDataBase.instance
        .readAllFavoriteOfCurrentUser(deviceId ?? "3")
        .asStream();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF4d047d),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4d047d),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "Favorite",
            style: GoogleFonts.archivo(
              fontStyle: FontStyle.normal,
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              wordSpacing: 0.34,
            ),
          ),
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
        ),
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFF4d047d),
        //   elevation: 0,
        //   automaticallyImplyLeading: false,
        //   centerTitle: true,
        //   title: Text(
        //     "Wallpapers",
        //     style: GoogleFonts.archivo(
        //       fontStyle: FontStyle.normal,
        //       color: Colors.white,
        //       fontSize: 22,
        //       fontWeight: FontWeight.w600,
        //       wordSpacing: 0.34,
        //     ),
        //   ),
        // ),
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
          child: StreamBuilder<List<Favorite>>(
              stream: refreshPost(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            "Not Found!",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              wordSpacing: 0.34,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 25,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8.0,
                            crossAxisSpacing: 5.0,
                            childAspectRatio: 3 / 6,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) {
                              return snapshot.data![index].type == "MUSIC"
                                  ? selectedIndex == index
                                      ? RingtoneGridviewCard(
                                          onRefresh: () {
                                            refreshPost();
                                            setState(() {});
                                          },
                                          auidoId:
                                              snapshot.data![index].deezeId,
                                          onNavigate: () async {
                                            await audioPlayer.pause();
                                            // ignore: use_build_context_synchronously
                                          },
                                          onChange: (value) async {
                                            final myposition = Duration(
                                                seconds: value.toInt());
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
                                                  snapshot.data![index].path);
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
                                          ringtoneName:
                                              snapshot.data![index].name,
                                          file: snapshot.data![index].path,
                                        )
                                      : RingtoneGridviewCard(
                                          onRefresh: () {
                                            refreshPost();
                                            setState(() {});
                                          },
                                          auidoId:
                                              snapshot.data![index].deezeId,
                                          onNavigate: () async {
                                            await audioPlayer.pause();
                                            // ignore: use_build_context_synchronously
                                          },
                                          onChange: (value) async {
                                            final myposition = Duration(
                                                seconds: value.toInt());
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
                                                snapshot.data![index].path,
                                              );
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
                                          ringtoneName:
                                              snapshot.data![index].name,
                                          file: snapshot.data![index].path,
                                        )
                                  : CategoryCard(
                                      iscategory: true,
                                      onRefresh: () {
                                        refreshPost();
                                        setState(() {});
                                      },
                                      id: snapshot.data![index].deezeId,
                                      index: index,
                                      image: snapshot.data![index].path,
                                      name: snapshot.data![index].name,
                                    );
                            },
                            childCount: snapshot.data!.length,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.green),
                  );
                }
                return Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFe8eaf9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ));
              }),
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
                  GestureDetector(
                    onTap: () {
                      refreshPost();
                      setState(() {});
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        children: [
                          const AppImageAsset(
                              image: 'assets/favourite_fill.svg'),
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
                          const AppImageAsset(image: "assets/wallpaper.svg"),
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
                  InkWell(
                    onTap: () async {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Dashbaord(
                            type: "RINGTONE",
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Row(
                        children: [
                          const AppImageAsset(image: 'assets/ringtone.svg'),
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
                          color: Colors.grey,
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
                        const AppImageAsset(
                          image: "assets/facebook.svg",
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 30),
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
}
