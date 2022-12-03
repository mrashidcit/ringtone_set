// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/widgets/more_audio_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:platform_device_id/platform_device_id.dart';

import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:social_share/social_share.dart';

import '../db_services/favorite_database.dart';
import '../models/deeze_model.dart';
import '../models/favorite.dart';
import '../uitilities/end_points.dart';

class WallPaperSlider extends StatefulWidget {
  final List<DeezeItemModel>? listHydra;
  final int? index;
  const WallPaperSlider({Key? key, this.listHydra, this.index})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WallPaperSliderState createState() => _WallPaperSliderState();
}

class _WallPaperSliderState extends State<WallPaperSlider> {
  final CarouselController _controller = CarouselController();
  late int activeIndex = 0;
  String file = "";
  animateToSilde(int index) => _controller.animateToPage(
        0,
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.listHydra!.removeRange(0, widget.index!);
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => animateToSilde(widget.index!));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loadData());
    file = widget.listHydra![0].file!;
  }

  int page = 1;
  Future<bool> fetchWallaper() async {
    var url = getDeezeAppHpUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      // "enabled": "true",
      "type": "WALLPAPER"
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

        widget.listHydra!.addAll(rawResponse);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future loadData() async {
    await Future.wait(widget.listHydra!
        .map((urlImage) => cacheImage(context, urlImage.file!))
        .toList());
  }

  Future cacheImage(BuildContext context, String urlImage) async {
    return precacheImage(CachedNetworkImageProvider(urlImage), context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print(file);
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: CachedNetworkImageProvider(file),
            fit: BoxFit.cover,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF965a90),
              Color(0xFF815d84),
              Color(0xFF56425d),
              Color(0xFF17131f),
              Color(0xFF17131f),
              Color(0xFF17131f),
            ],
          ),
        ),
        child: Stack(
          children: [
            const AppImageAsset(
                image: 'assets/drop_shadow.png',
                height: double.infinity,
                fit: BoxFit.cover),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Column(
                children: [
                  CarouselSlider.builder(
                    carouselController: _controller,
                    itemCount: widget.listHydra!.length,
                    itemBuilder: (context, index, realIndex) {
                      final urlImage = widget.listHydra![index].file!;

                      // file = index == 0
                      //     ? widget.listHydra![0].file!
                      //     : widget.listHydra![index - 1].file!;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BuildImage(
                            urlImage: urlImage,
                            index: activeIndex,
                            userName: widget.listHydra![index].user!.firstName!,
                            userProfileUrl:
                                widget.listHydra![index].user!.image,
                            // isFavourite: widget.listHydra![index].isFavourite,
                            file: widget.listHydra![index].file!,
                            id: widget.listHydra![index].id!,
                            name: widget.listHydra![index].name!,
                          ),
                          if (activeIndex == index) const SizedBox(height: 10),
                          if (activeIndex == index)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    widget.listHydra![activeIndex].user!
                                                .image !=
                                            null
                                        ? CircleAvatar(
                                            radius: 15,
                                            backgroundImage: NetworkImage(
                                              widget.listHydra![activeIndex]
                                                  .user!.image!,
                                            ),
                                          )
                                        : const CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            radius: 15,
                                          ),
                                    const SizedBox(width: 15),
                                    Text(
                                      widget.listHydra![activeIndex].user!
                                          .firstName!,
                                      style: GoogleFonts.archivo(
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                        fontSize: 15,
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
                        ],
                      );
                    },
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.9,
                      viewportFraction: 0.75,
                      enableInfiniteScroll: false,
                      pageSnapping: true,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          page = index;
                        });
                        fetchWallaper();
                        setState(() {
                          file = widget.listHydra![index].file!;
                          activeIndex = index;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.8),
                            builder: (context) {
                              return MoreAudioDialog(
                                file: '',
                                fileName: widget.listHydra![activeIndex].name!,
                                userName: widget
                                    .listHydra![activeIndex].user!.firstName!,
                                userImage:
                                    widget.listHydra![activeIndex].user!.image!,
                              );
                            },
                          );
                        },
                        child: const AppImageAsset(
                            image: 'assets/dot.svg',
                            color: Colors.white,
                            height: 6),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            barrierColor: Colors.black.withOpacity(0.8),
                            builder: (context) =>
                                WallpaperSelectDialog(file: file),
                          );
                        },
                        child: const AppImageAsset(
                            image: 'assets/wallpaper_down.svg', height: 50),
                      ),
                      const SizedBox(width: 30),
                      GestureDetector(
                        onTap: () {
                          var item = widget.listHydra![activeIndex];
                          SocialShare.shareOptions("${item.file!}");
                          ;
                        },
                        child: const AppImageAsset(
                            image: 'assets/share.svg',
                            color: Colors.white,
                            height: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuildImage extends StatefulWidget {
  String urlImage;
  int index;
  String name;
  String file;
  int id;
  String userName;
  String? userProfileUrl;
  BuildImage({
    Key? key,
    required this.urlImage,
    required this.index,
    required this.name,
    required this.file,
    required this.id,
    required this.userName,
    this.userProfileUrl,
  }) : super(key: key);

  @override
  State<BuildImage> createState() => _BuildImageState();
}

class _BuildImageState extends State<BuildImage> {
  List<Favorite> favoriteList = [];

  refreshFavorite() async {
    favoriteList = await FavoriteDataBase.instance
        .readAllFavoriteOfCurrentMusic(widget.id.toString());
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
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          SizedBox(
            height: 500,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AppImageAsset(
                image: widget.urlImage,
                isWebImage: true,
                webFit: BoxFit.cover,
                webWidth: double.infinity,
              ),
            ),
          ),
          GestureDetector(
            onTap: (() async {
              String? deviceId = await PlatformDeviceId.getDeviceId;

              Favorite favorite = Favorite(
                  name: widget.name,
                  currentDeviceId: deviceId!,
                  path: widget.file,
                  deezeId: widget.id.toString(),
                  type: "WALLPAPER");
              favoriteList.isEmpty
                  ? await FavoriteDataBase.instance.addFavorite(favorite)
                  : await FavoriteDataBase.instance
                      .delete(favoriteList.first.deezeId);
              refreshFavorite();
            }),
            child: favoriteList.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: AppImageAsset(
                          image: 'assets/favourite.svg', height: 16),
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: AppImageAsset(
                        image: "assets/favourite_fill.svg",
                        color: Colors.red,
                        height: 16,
                        width: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class WallpaperSelectDialog extends StatefulWidget {
  final String file;
  const WallpaperSelectDialog({Key? key, required this.file}) : super(key: key);

  @override
  State<WallpaperSelectDialog> createState() => _WallpaperSelectDialogState();
}

class _WallpaperSelectDialogState extends State<WallpaperSelectDialog> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  bool isloading = false;
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}
  Future<bool> setWallpaper() async {
    try {
      String url = widget.file;
      int location = WallpaperManager
          .HOME_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      return result;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> downloadFile(String url) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File("${appStorage.path}/wallpaper.png");
    try {
      final response = await Dio().get(url,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: 0));
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      raf.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setLockWallpaper() async {
    try {
      String url = widget.file;
      int location = WallpaperManager
          .LOCK_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      return result;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> setBothScreenWallpaper() async {
    try {
      String url = widget.file;
      int location = WallpaperManager
          .BOTH_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
      var file = await DefaultCacheManager().getSingleFile(url);
      final bool result =
          await WallpaperManager.setWallpaperFromFile(file.path, location);
      return result;
    } on PlatformException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.14),
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 350,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 180,
                    alignment: Alignment.centerLeft,
                    child: const AppImageAsset(
                      image: 'assets/bakward_arrow.svg',
                      height: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    final isSucces = await setWallpaper();
                    if (isSucces) {
                      Fluttertoast.showToast(
                        msg: "Wallpaper succesfully Updated!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: const Color(0xFF7209b7),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/call_drop.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET WALLPAPER',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () async {
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    final isSucces = await setLockWallpaper();
                    if (isSucces) {
                      Fluttertoast.showToast(
                        msg: "Wallpaper succesfully Updated!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: const Color(0xFF7209b7),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/bell.svg',
                            height: 20,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET LOCK SCREEN',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: () async {
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    final isSucces = await setBothScreenWallpaper();
                    if (isSucces) {
                      Fluttertoast.showToast(
                        msg: "Wallpaper succesfully Updated!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: const Color(0xFF7209b7),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/bell_clock.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET BOTH',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                InkWell(
                  onTap: () async {
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    final sucess = await downloadFile(widget.file);
                    var snackBar;
                    if (sucess) {
                      print("sucess");
                      Fluttertoast.showToast(
                        msg: "Wallpaper succesfully Downloaded",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        backgroundColor: const Color(0xFF7209b7),
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 50,
                        width: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[
                              Color(0xFF3C99CA),
                              Color(0xFF7541A0),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppImageAsset(
                                image: 'assets/save_down.svg', height: 14),
                            const SizedBox(width: 20),
                            Text(
                              'SAVE TO MEDIA',
                              style: GoogleFonts.archivo(
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: -6,
                        right: -10,
                        child: AppImageAsset(image: 'assets/premium_badge.svg'),
                      ),
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
}
