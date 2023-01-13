import 'dart:io';

import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/repositories/item_repository.dart';
import 'package:deeze_app/repositories/user_repository.dart';
import 'package:deeze_app/screens/custom_widgets/custom_drawer.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/drawer_header.dart';
import 'package:deeze_app/widgets/wallpaper_dispaly.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool isDeleted = false;
  int selectedIndex = -1;
  XFile? _selectedProfileImage;
  bool _showProfileUploadingProgressBar = false;
  List<DeezeItemModel> _itemsList = [];
  var _isItemLoading = true;
  var _showBottomItemLoadingProgressBar = false;
  bool _deleteItemProgressBar = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();
  }

  void fetchData() async {
    var itemResponse = await ItemRepository().getRandomItemsResponse();

    if (itemResponse.result) {
      _itemsList.addAll(itemResponse.itemList);
      _isItemLoading = false;
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unable to load Data!'),
      ));
    }
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

  Future<void> performDeleteItem(ctx, int itemId, setState) async {
    var deleteResponse =
        await ItemRepository().getDeleteItemResponse(itemId: itemId);

    _deleteItemProgressBar = true;
    if (deleteResponse.result) {
      showToast(ctx, message: deleteResponse.message);
    } else {
      showToast(ctx, message: deleteResponse.message);
    }
    _deleteItemProgressBar = false;
    setState(() {});
  }

  Expanded profilePostView(double screenWidth, BuildContext context) {
    return Expanded(
      child: GridView(
        primary: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 5.0,
          crossAxisSpacing: 5.0,
          childAspectRatio: 3 / 6,
        ),
        shrinkWrap: true,
        children: List.generate(
          _itemsList.length,
          (index) => Stack(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WallPaperSlider(
                        listHydra: _itemsList,
                        index: index,
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
              if (selectedIndex == index)
                Container(
                  width: screenWidth * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              Positioned(
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
                                          borderRadius:
                                              BorderRadius.circular(20),
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
                                                  color:
                                                      const Color(0XFFA49FAD),
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
                                                        Navigator.of(context)
                                                            .pop(),
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
                                                                .circular(16),
                                                      ),
                                                      child: Text(
                                                        'Cancel',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style:
                                                            GoogleFonts.archivo(
                                                          fontStyle:
                                                              FontStyle.normal,
                                                          color: Colors.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
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
                                                                _itemsList[
                                                                        index]
                                                                    .id!,
                                                                setState);
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            setState(() =>
                                                                selectedIndex =
                                                                    -1);
                                                          },
                                                          child: Container(
                                                            height: 40,
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        10,
                                                                    horizontal:
                                                                        30),
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                              gradient:
                                                                  const LinearGradient(
                                                                begin: Alignment
                                                                    .bottomLeft,
                                                                end: Alignment
                                                                    .bottomRight,
                                                                colors: [
                                                                  Color(
                                                                      0XFF7209B7),
                                                                  Color(
                                                                      0XFF5945CE),
                                                                ],
                                                              ),
                                                            ),
                                                            child: Text(
                                                              'Delete',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: GoogleFonts
                                                                  .archivo(
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
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
                      Text(
                        'Share',
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
