import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/setting.dart';
import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/screens/web_view/show_web_page.dart';
import 'package:deeze_app/uitilities/constants.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/drawer_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
              InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (ctx) =>
                            Dashbaord(type: ItemType.NOTIFICATION.name)),
                    (route) => false,
                  );
                },
                child: Padding(
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
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
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
                      const AppImageAsset(image: 'assets/favourite_fill.svg'),
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
              InkWell(
                onTap: () async {
                  // print('>> onTap - rateMyApp');
                  // RateMyApp rateMyApp = RateMyApp(
                  //   preferencesPrefix: 'rateMyApp_',
                  //   minDays: 7,
                  //   minLaunches: 10,
                  //   remindDays: 7,
                  //   remindLaunches: 10,
                  //   googlePlayIdentifier: 'com.aggyapps.top2015.ringtones',
                  //   appStoreIdentifier: '1491556149',
                  // );

                  // await rateMyApp.callEvent(
                  //     RateMyAppEventType.rateButtonPressed);

                  if (Platform.isAndroid) {
                    AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: "market://details?id=" + Constants.PackageId,
                      arguments: {},
                    );
                    await intent.launch();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 37),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Rate Us",
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
              ),
              const SizedBox(
                height: 25,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();

                  Navigator.push(context,
                      MaterialPageRoute(builder: (ctx) => SettingScreen()));
                },
                child: Padding(
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
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ShowWebPage(
                        url:
                            'https://sites.google.com/view/aggyapps/privacy-policy',
                        title: 'Privacy Policy',
                      ),
                    ),
                  );
                },
                child: Padding(
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
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => ShowWebPage(
                        url: 'https://www.facebook.com/DeezeOfficial',
                        title: 'Join Us on Facebook',
                      ),
                    ),
                  );
                },
                child: Padding(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
