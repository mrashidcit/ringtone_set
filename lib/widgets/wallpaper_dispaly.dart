// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/ad_helper.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/repositories/item_repository.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:deeze_app/widgets/more_audio_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool loadCurrentUserItemsOnly = false;
  WallPaperSlider(
      {Key? key,
      this.listHydra,
      this.index,
      this.loadCurrentUserItemsOnly = false})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WallPaperSliderState createState() => _WallPaperSliderState();
}

class _WallPaperSliderState extends State<WallPaperSlider> {
  final CarouselController _controller = CarouselController();
  late int activeIndex = 0;
  String file = "";
  bool _noMoreDataFound = false;
  BannerAd? _bannerAd;

  animateToSilde(int index) => _controller.animateToPage(
        0,
        duration: Duration(milliseconds: 100),
        curve: Curves.linear,
      );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    widget.listHydra!.removeRange(0, widget.index!);
    WidgetsBinding.instance
        .addPostFrameCallback((timeStamp) => animateToSilde(widget.index!));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loadData());
    file = widget.listHydra![0].file!;
  }

  int page = 1;
  Future<bool> fetchWallaper() async {
    print('>> fetchWallaper');

    if (widget.loadCurrentUserItemsOnly) {
      setState(() {});
      var itemResponse = await ItemRepository().getCurrentUserItemsResponse(
        itemType: ItemType.WALLPAPER,
        pageNumber: page,
      );
      print(
          '>> fetchWallaper - itemResponse.result , itemResponse.itemList.length : ${itemResponse.result} , ${itemResponse.itemList.length} ');
      if (itemResponse.result) {
        if (itemResponse.itemList.length > 0) page++;
        widget.listHydra!.addAll(itemResponse.itemList);
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
      body: Column(
        children: [
          Expanded(
            child: Container(
              // height: MediaQuery.of(context).size.height,
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
                          itemCount: widget.listHydra!.length + 1,
                          itemBuilder: (context, index, realIndex) {
                            if (index > widget.listHydra!.length - 1) {
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
                              final urlImage = widget.listHydra![index].file!;
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  BuildImage(
                                    urlImage: urlImage,
                                    index: activeIndex,
                                    userName: widget
                                        .listHydra![index].user!.firstName!,
                                    userProfileUrl:
                                        widget.listHydra![index].user!.image,
                                    // isFavourite: widget.listHydra![index].isFavourite,
                                    file: widget.listHydra![index].file!,
                                    id: widget.listHydra![index].id!,
                                    name: widget.listHydra![index].name!,
                                  ),
                                  if (activeIndex == index)
                                    const SizedBox(height: 10),
                                  if (activeIndex == index)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            widget.listHydra![activeIndex].user!
                                                        .image !=
                                                    null
                                                ? CircleAvatar(
                                                    radius: 15,
                                                    backgroundImage:
                                                        NetworkImage(
                                                      widget
                                                          .listHydra![
                                                              activeIndex]
                                                          .user!
                                                          .image!,
                                                    ),
                                                  )
                                                : const CircleAvatar(
                                                    backgroundColor:
                                                        Colors.grey,
                                                    radius: 15,
                                                  ),
                                            const SizedBox(width: 15),
                                            Text(
                                              widget.listHydra![activeIndex]
                                                  .user!.firstName!,
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
                            }
                          },
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.9 -
                                (_bannerAd != null ? 52 : 0),
                            viewportFraction: 0.75,
                            enableInfiniteScroll: false,
                            pageSnapping: true,
                            enlargeCenterPage: true,
                            onPageChanged: (index, reason) {
                              if (index > widget.listHydra!.length - 1) {
                                setState(() {
                                  page = index;
                                  activeIndex = index;
                                });
                                if (!_noMoreDataFound) fetchWallaper();
                              } else {
                                setState(() {
                                  page = index;
                                  file = widget.listHydra![index].file!;
                                  activeIndex = index;
                                });
                              }
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
                                      fileName:
                                          widget.listHydra![activeIndex].name!,
                                      userName: widget.listHydra![activeIndex]
                                          .user!.firstName!,
                                      userImage: widget
                                          .listHydra![activeIndex].user!.image!,
                                      tags: widget.listHydra![activeIndex].tags,
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
                                  image: 'assets/wallpaper_down.svg',
                                  height: 50),
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
          ),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _bannerAd?.dispose();
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
      height: 400,
      child: Stack(
        children: [
          SizedBox(
            height: 400,
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

  Future<bool> downloadFile(String url, String fileName) async {
    Directory directory;
    try {
      if (await _requestStoragePermission()) {
        directory = (await getExternalStorageDirectory())!;
        String newPath = "";

        print(directory);
        List<String> paths = directory.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + '/Pictures' + "/DeezePlayer";
        directory = Directory(newPath);
      } else {
        return false;
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        print('>> saveFile : ${saveFile.path}');
        final response = await Dio().get(url,
            options: Options(
                responseType: ResponseType.bytes,
                followRedirects: false,
                receiveTimeout: 0));
        final raf = saveFile.openSync(mode: FileMode.write);
        raf.writeFromSync(response.data);
        raf.close();
      }

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
                  onTap: actionSaveToMedia,
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

  Future<bool> _requestStoragePermission() async {
    bool output = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 23 && sdkInt <= 29) {
        PermissionStatus storageStatus = await Permission.storage.status;
        if ((storageStatus.isDenied || storageStatus.isPermanentlyDenied)) {
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();
          }

          output = storageStatus.isGranted;
        } else if (storageStatus.isGranted || storageStatus.isLimited) {
          output = true;
        } else {
          output = false;
        }
      } else {
        // for API level 29 & Above
        print('>> for API level 30 & Above ');
        show_openAppAd.$ = false;
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;

        print(
            '>> managedExternalStorageStatus.isGranted : ${managedExternalStorageStatus.isGranted}');
        print(
            '>> managedExternalStorageStatus.isDenied : ${managedExternalStorageStatus.isDenied}');
        print(
            '>> managedExternalStorageStatus.isPermanentlyDenied : ${managedExternalStorageStatus.isPermanentlyDenied}');
        print(
            '>> managedExternalStorageStatus.isRestricted : ${managedExternalStorageStatus.isRestricted}');
        if (!managedExternalStorageStatus.isGranted) {
          managedExternalStorageStatus =
              await Permission.manageExternalStorage.request();
          // managedExternalStorageStatus = await Permission.storage.request();

          output = managedExternalStorageStatus.isGranted;
          print(
              '>> after tigger setting - managedExternalStorageStatus.isGranted : ${managedExternalStorageStatus.isRestricted}');
        } else if (managedExternalStorageStatus.isGranted ||
            managedExternalStorageStatus.isLimited) {
          output = true;
        } else {
          output = false;
        }
      }
      show_openAppAd.$ = true;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      print('>> Android $release (SDK $sdkInt), $manufacturer $model');
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    }

    return output;
  }

  Future<void> actionSaveToMedia() async {
    if (!await InternetConnectionChecker().hasConnection) {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) => InternetCheckerDialog(
          onRetryTap: () {
            Navigator.pop(context); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500), () => actionSaveToMedia());
          },
        ),
      );
      return;
    }
    bool storagePermissionStatus = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;
        print(
            '>> actionSetRingTone - sdkInt , Permission.manageExternalStorage.status.isGranted : $sdkInt , ${managedExternalStorageStatus.isGranted}');

        if (managedExternalStorageStatus.isGranted) {
          storagePermissionStatus = true;
        } else {
          print('>> actionSetRingTone : _requestStoragePermission');

          _requestStoragePermission();
          return;
        }
      } else {
        storagePermissionStatus = await _requestStoragePermission();
      }
    }

    if (!storagePermissionStatus) {
      showMessage(context, message: "Storage Permission is Required");
      return;
    }

    bool success = false;

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
    try {
      success = await downloadFile(widget.file, widget.file.split('/').last);
      pd.dismiss();
    } on PlatformException {
      success = false;
    }

    if (success) {
      showMessage(context, message: "Your File successfully Downloaded");
    } else {
      showMessage(context, message: "Try again!");
    }
    Navigator.pop(context);
  }
}
