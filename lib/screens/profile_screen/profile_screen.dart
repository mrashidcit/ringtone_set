import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/random_item_response.dart';
import 'package:deeze_app/repositories/item_repository.dart';
import 'package:deeze_app/repositories/user_repository.dart';
import 'package:deeze_app/screens/auth/onboarding.dart';
import 'package:deeze_app/screens/custom_widgets/custom_drawer.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/upload_screen/upload_screen.dart';
import 'package:deeze_app/screens/upload_screen/widgets/processing_ringtones_card.dart';
import 'package:deeze_app/screens/upload_screen/widgets/profile_ringtones_card.dart';
import 'package:deeze_app/screens/upload_screen/widgets/upload_ringtones_card.dart';
import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/uitilities/constants.dart';
import 'package:deeze_app/uitilities/my_theme.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/audio_player.dart';
import 'package:deeze_app/widgets/drawer_header.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:deeze_app/widgets/ringtones_card.dart';
import 'package:deeze_app/widgets/unauthorized_check_dialog.dart';
import 'package:deeze_app/widgets/wallpaper_dispaly.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_state_manager/src/simple/list_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:social_share/social_share.dart';
import 'package:selection_menu/selection_menu.dart';
import 'package:selection_menu/components_configurations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with WidgetsBindingObserver {
  bool isDeleted = false;
  int selectedIndex = -1;
  XFile? _selectedProfileImage;
  bool _showProfileUploadingProgressBar = false;
  List<DeezeItemModel> _itemsList = [];
  var _isItemLoading = true;
  var _showBottomItemLoadingProgressBar = false;
  bool _deleteItemProgressBar = false;
  bool _showMainProgressBar = false;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  int _itemPageNo = 1;
  ItemType _selectedItemType = ItemType.WALLPAPER;

  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer pausePlayer = AudioPlayer();
  bool isPlaying = false;
  bool _isBuffering = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Duration pauseDuration = Duration.zero;
  Duration pausePosition = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    fetchData();

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
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    audioPlayer.dispose();
    isPlaying = false;
    PlayerState.STOPPED;
  }

  Future<RandomItemResponse> fetchData(
      {refreshData = false, isLoadingNextPage = false}) async {
    if (refreshData) {
      _itemPageNo = 1;
      _itemsList.clear();
      _isItemLoading = true;
    }
    if (isLoadingNextPage) {
      _showBottomItemLoadingProgressBar = true;
    }

    setState(() {});
    var itemResponse = await ItemRepository().getCurrentUserItemsResponse(
      itemType: _selectedItemType,
      pageNumber: _itemPageNo,
    );
    if (itemResponse.result) {
      _itemPageNo++;
      _itemsList.addAll(itemResponse.itemList);
      if (itemResponse.itemList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No Data Found!'),
        ));
      }
    } else {
      if (itemResponse.statusCode == Constants.statusCodeForUnauthorized) {
        showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => UnAuthorizedCheckDialog(
            onRetryTap: () {
              Navigator.pop(ctx); // Hide Internet Message Dialog
              Timer(Duration(milliseconds: 500), () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OnBoarding()),
                );
              });
            },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Unable to load Data!'),
        ));
      }
    }

    _isItemLoading = false;
    if (isLoadingNextPage) _showBottomItemLoadingProgressBar = false;
    setState(() {});

    return itemResponse;
  }

  void resetValues() {
    _itemsList.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 60),
        child: AppBar(
          backgroundColor: const Color(0xFF4d047d),
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (ctx) {
              return GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: AppImageAsset(image: 'assets/menu.svg'),
                ),
              );
            },
          ),
          title: Text(
            'Profile',
            style: GoogleFonts.archivo(
              fontStyle: FontStyle.normal,
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              wordSpacing: 0.34,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: AppImageAsset(image: 'assets/setting.svg'),
            ),
          ],
        ),
      ),
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
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Column(
                  children: [
                    Text(
                      '120',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 0.22,
                      ),
                    ),
                    Text(
                      'Followers',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontStyle: FontStyle.normal,
                        fontSize: 12,
                        color: const Color(0XFFA49FAD),
                        letterSpacing: 0.17,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Stack(
                  children: [
                    Container(
                      height: 65,
                      width: 65,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0XFFDAD8DF),
                        shape: BoxShape.circle,
                      ),
                      // child: AppImageAsset(
                      //   image: (_selectedProfileImage == null)
                      //       ? 'assets/dummy_profile.svg'
                      //       : _selectedProfileImage!.path,
                      //   height: 55,
                      // ),
                      child: buildProfileImageAvatar(),
                    ),
                    _showProfileUploadingProgressBar
                        ? Positioned.fill(
                            child: Align(
                                alignment: Alignment.center,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.transparent,
                                )),
                          )
                        : SizedBox(),
                    Positioned(
                      right: 4,
                      top: 2,
                      child: InkWell(
                        onTap: () async {
                          show_openAppAd.$ = false;
                          final ImagePicker _picker = ImagePicker();
                          // Pick an image
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery,
                          );

                          _selectedProfileImage =
                              image ?? _selectedProfileImage;

                          show_openAppAd.$ = true;

                          if (_selectedProfileImage != null) {
                            setState(() {
                              _showProfileUploadingProgressBar = true;
                            });
                            var fileUploadResponse = await UserRepository()
                                .uploadFileResponse(_selectedProfileImage!);

                            if (fileUploadResponse.result) {
                              var userProfileUpdateResponse =
                                  await UserRepository()
                                      .updateUserProfileImageResponse(
                                          fileUploadResponse
                                              .fileModel!.fileName);

                              if (userProfileUpdateResponse.result) {
                                saveUserInCache(
                                    userProfileUpdateResponse.user!);
                                var snackBar = SnackBar(
                                  content: Text('Successfully Updated!'),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            }
                          }

                          setState(() {
                            _showProfileUploadingProgressBar = false;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const AppImageAsset(
                              image: 'assets/add.svg',
                              height: 8,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text(
                      '20',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontStyle: FontStyle.normal,
                        fontSize: 16,
                        color: Colors.white,
                        letterSpacing: 0.22,
                      ),
                    ),
                    Text(
                      'Following',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.archivo(
                        fontStyle: FontStyle.normal,
                        fontSize: 12,
                        color: const Color(0XFFA49FAD),
                        letterSpacing: 0.17,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: Text(
                    'My Items',
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                // SelectionMenu<String>(
                //   itemsList: <String>['A', 'B', 'C'],
                //   onItemSelected: (String selectedItem) {
                //     print(selectedItem);
                //   },
                //   itemBuilder: (BuildContext context, String item,
                //       OnItemTapped onItemTapped) {
                //     return Material(
                //       child: InkWell(
                //         onTap: () {

                //         },
                //         child: Text(item),
                //       ),
                //     );
                //   },
                //   // other Properties...
                // )
                SelectionMenu<ItemType>(
                  initiallySelectedItemIndex: 0,
                  itemsList: <ItemType>[
                    ItemType.WALLPAPER,
                    ItemType.RINGTONE,
                    ItemType.NOTIFICATION
                  ],
                  onItemSelected: (ItemType selectedItem) {
                    _selectedItemType = selectedItem;
                    resetValues();
                    fetchData(refreshData: true);
                  },
                  itemBuilder: (BuildContext ctx, ItemType item,
                      OnItemTapped onItemTapped) {
                    return Material(
                      child: InkWell(
                        onTap: onItemTapped,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.name,
                          ),
                        ),
                      ),
                    );
                  },
                  showSelectedItemAsTrigger: true,
                  closeMenuInsteadOfPop: true,
                  closeMenuOnItemSelected: true,
                  // other Properties...
                )
              ],
            ),
            _showMainProgressBar
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LoadingPage(),
                    ],
                  )
                : Center(),
            const SizedBox(height: 4),
            _isItemLoading
                ? Expanded(child: LoadingPage())
                : profilePostView(screenWidth, context),
          ],
        ),
      ),
      drawer: CustomDrawer(),
    );
  }

  Widget buildProfileImageAvatar() {
    if (_selectedProfileImage != null) {
      return CircleAvatar(
        backgroundImage: FileImage(File(_selectedProfileImage!.path)),
        radius: 35,
      );
    } else if (user_profile_image.$.isNotEmpty) {
      return CircleAvatar(
        backgroundImage: NetworkImage(user_profile_image.$),
        radius: 35,
      );
    } else {
      return AppImageAsset(
        image: (_selectedProfileImage == null)
            ? 'assets/dummy_profile.svg'
            : _selectedProfileImage!.path,
        height: 55,
      );
    }
  }

  Future<void> performDeleteItem(ctx, int itemId, itemIndex, setState) async {
    _deleteItemProgressBar = true;
    setState(() {});
    var deleteResponse =
        await ItemRepository().getDeleteItemResponse(itemId: itemId);

    if (deleteResponse.result) {
      showMessage(context, message: deleteResponse.message);
      _itemsList.removeAt(itemIndex);
    } else {
      showMessage(context, message: deleteResponse.message);
    }
    _deleteItemProgressBar = false;
    setState(() {});
  }

  Expanded profilePostView(double screenWidth, BuildContext context) {
    return Expanded(
      child: Container(
        child: SmartRefresher(
          enablePullUp: true,
          controller: _refreshController,
          onRefresh: () async {
            print('>> dashboard - SmartRefresher - onRefresh');
            final response = await fetchData(refreshData: true);
            if (response.result) {
              _refreshController.refreshCompleted();
            } else {
              _refreshController.refreshFailed();
            }
          },
          onLoading: () async {
            print('>> dashboard - SmartRefresher - onLoading');
            final response = await fetchData(isLoadingNextPage: true);
            if (response.result) {
              _refreshController.loadComplete();
            } else {
              _refreshController.loadFailed();
            }
          },
          header: CustomHeader(builder: (context, mode) => SizedBox()),
          footer: CustomFooter(builder: (context, mode) {
            print('>> CustomFooter - isDataLoad , totalPage :');
            return _showBottomItemLoadingProgressBar
                ? const LoadingPage()
                : const SizedBox();
          }),
          child: GridView(
            primary: true,
            // physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (_selectedItemType == ItemType.WALLPAPER) ? 3 : 1,
              mainAxisSpacing: 5.0,
              crossAxisSpacing: 5.0,
              childAspectRatio:
                  (_selectedItemType == ItemType.WALLPAPER) ? 3 / 6 : 3.6 / 1,
            ),
            shrinkWrap: true,
            children: List.generate(
              _itemsList.length + 1,
              (index) {
                if (_selectedItemType == ItemType.WALLPAPER) {
                  if (index == 0)
                    return buildWallpaperCardToUploadeItemWidget(context);
                  else
                    return buildWallpaperCardWidget(
                        context, index - 1, screenWidth);
                } else {
                  if (index == 0)
                    return buildUploadRingtoneCard(0, context);
                  else
                    return _itemsList[index - 1].enabled
                        ? buildRingtoneCard(index - 1, context)
                        : buildProcessingRingtoneCard(context);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  ProfileRingtonesCard buildRingtoneCard(int index, BuildContext context) {
    return ProfileRingtonesCard(
      auidoId: _itemsList[index].id!.toString(),
      onNavigate: () async {
        print('>> dashboard - onNavigate - activeCard - index = $index');
        await audioPlayer.pause();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomAudioPlayer(
              listHydra: _itemsList.sublist(index),
              // index: index,
              index: 0,
              type: _selectedItemType.name,
              loadCurrentUserItemsOnly: true,
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
        await onTapRingtoneCardFunction(index);
      }),
      onTapDelete: (itemIndex) {
        showDeleteConfirmationDialog(itemIndex);
      },
      audioPlayer: selectedIndex == index ? audioPlayer : pausePlayer,
      isPlaying: selectedIndex == index ? isPlaying : false,
      isBuffering: selectedIndex == index ? _isBuffering : false,
      duration: selectedIndex == index ? duration : pauseDuration,
      position: selectedIndex == index ? position : pausePosition,
      index: index,
      listHydra: _itemsList,
      ringtoneName: _itemsList[index].name!,
      file: _itemsList[index].file!,
    );
  }

  UploadRingtonesCardForProfileScreen buildUploadRingtoneCard(
      int index, BuildContext context) {
    return UploadRingtonesCardForProfileScreen(onNavigate: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const UploadScreen(),
        ),
      );
    });
  }

  ProcessingRingtonesCard buildProcessingRingtoneCard(BuildContext context) {
    return ProcessingRingtonesCard(onNavigate: () {
      showMessage(context,
          message:
              'This item is Under Review. \nIt will be shown you when Admin Approve this.');
    });
  }

  Future<void> onTapRingtoneCardFunction(int index) async {
    print(
        '>> onTapRingtoneCardFunction - index , selectedIndex = $index , $selectedIndex');

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
                () => onTapRingtoneCardFunction(index));
          }),
        );
      } else {
        setState(() {
          _isBuffering = true;
          position = Duration.zero;
        });
        // await audioPlayer.play(hydraMember[index].file!);
        await audioPlayer.play(_itemsList[index].file!);
      }
    }
  }

  Stack buildWallpaperCardWidget(
      BuildContext context, int index, double screenWidth) {
    return Stack(
      children: [
        Container(
          // height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromRGBO(166, 125, 17, 1),
                const Color.fromRGBO(129, 84, 87, 1),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.0, 1.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
            borderRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
        Visibility(
          visible: _itemsList[index].enabled,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WallPaperSlider(
                    listHydra: _itemsList,
                    index: index,
                    loadCurrentUserItemsOnly: true,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: screenWidth * 0.4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AppImageAsset(
                  image: _itemsList[index].file,
                  isWebImage: true,
                  webHeight: double.infinity,
                  webFit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
        if (selectedIndex == index)
          Container(
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        Visibility(
          visible: _itemsList[index].enabled,
          child: Positioned(
            top: 10,
            right: 5,
            child: GestureDetector(
              onTap: () {
                if (selectedIndex != index)
                  selectedIndex = index;
                else
                  selectedIndex = -1;
                setState(() {});
              },
              child: const AppImageAsset(
                image: 'assets/horizontal_more.svg',
                height: 12,
              ),
            ),
          ),
        ),
        if (selectedIndex == index)
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return StatefulBuilder(
                            builder: ((context, setState) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 60),
                                alignment: Alignment.bottomCenter,
                                child: Card(
                                  elevation: 10,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 30),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Are you sure you want to delete ?',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.archivo(
                                            fontStyle: FontStyle.normal,
                                            color: const Color(0XFFA49FAD),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () =>
                                                  Navigator.of(context).pop(),
                                              child: Container(
                                                height: 40,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 30),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                child: Text(
                                                  'Cancel',
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.archivo(
                                                    fontStyle: FontStyle.normal,
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            _deleteItemProgressBar
                                                ? RefreshProgressIndicator()
                                                : InkWell(
                                                    onTap: () async {
                                                      await performDeleteItem(
                                                          context,
                                                          _itemsList[index].id!,
                                                          index,
                                                          setState);
                                                      Navigator.of(context)
                                                          .pop();
                                                      setState(() =>
                                                          selectedIndex = -1);
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 10,
                                                          horizontal: 30),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        gradient:
                                                            const LinearGradient(
                                                          begin: Alignment
                                                              .bottomLeft,
                                                          end: Alignment
                                                              .bottomRight,
                                                          colors: [
                                                            Color(0XFF7209B7),
                                                            Color(0XFF5945CE),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Text(
                                                        'Delete',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.archivo(
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                        const SizedBox(height: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        });
                  },
                  child: Text(
                    'Delete',
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    SocialShare.shareOptions("${_itemsList[index].file}");
                  },
                  child: Text(
                    'Share',
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                )
              ],
            ),
          ),
        Visibility(
          visible: !_itemsList[index].enabled ? true : false,
          child: Center(
            child: const AppImageAsset(
              image: 'assets/sand-clock.png',
              height: 20,
            ),
          ),
        ),
        Positioned(
            bottom: 4,
            left: 2,
            child: Text(
              !_itemsList[index].enabled ? 'Processing ...' : '',
              style: TextStyle(color: MyTheme.white),
            ))
      ],
    );
  }

  Widget buildWallpaperCardToUploadeItemWidget(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => const UploadScreen(),
            //   ),
            // );
          },
          child: Container(
            // height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    const Color.fromRGBO(103, 0, 214, 1),
                    const Color.fromRGBO(190, 133, 104, 1),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(0.9, .7),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
          ),
        ),
        Center(
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UploadScreen(),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.file_upload_outlined,
                    color: MyTheme.white,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upload',
                    style: TextStyle(
                      color: MyTheme.white,
                      fontSize: 14,
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  void showDeleteConfirmationDialog(int index) {
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return Container(
                margin: const EdgeInsets.only(bottom: 60),
                alignment: Alignment.bottomCenter,
                child: Card(
                  elevation: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Are you sure you want to delete ?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: const Color(0XFFA49FAD),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 30),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Cancel',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            _deleteItemProgressBar
                                ? RefreshProgressIndicator()
                                : InkWell(
                                    onTap: () async {
                                      await performDeleteItem(
                                          context,
                                          _itemsList[index].id!,
                                          index,
                                          setState);

                                      Navigator.of(context).pop();
                                      notifyItemDelete(index);
                                    },
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 30),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                          begin: Alignment.bottomLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0XFF7209B7),
                                            Color(0XFF5945CE),
                                          ],
                                        ),
                                      ),
                                      child: Text(
                                        'Delete',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.archivo(
                                          fontStyle: FontStyle.normal,
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        });
  }

  void notifyItemDelete(int index) {
    // _itemsList.removeAt(index);
    selectedIndex = -1;
    setState(() {});
  }
}
