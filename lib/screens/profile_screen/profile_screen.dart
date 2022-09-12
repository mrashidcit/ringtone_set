import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/drawer_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool isDeleted = false;
  int selectedIndex = -1;

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
                      child: const AppImageAsset(
                        image: 'assets/dummy_profile.svg',
                        height: 55,
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          padding: const EdgeInsets.all(2),
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
                    )
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
            profilePostView(screenWidth, context),
          ],
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
                const MyDrawerHeader(showProfile: false),
                const SizedBox(height: 40),
                InkWell(
                  onTap: () async {
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
                        const AppImageAsset(image: "assets/ringtone.svg"),
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
                        const SizedBox(width: 26),
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
                      const AppImageAsset(image: "assets/bell.svg"),
                      const SizedBox(width: 20),
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
                const SizedBox(height: 30),
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
                        const AppImageAsset(image: "assets/drawer_fav.svg"),
                        const SizedBox(width: 29),
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
                      const AppImageAsset(image: "assets/facebook.svg"),
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
    );
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
          16,
          (index) => Stack(
            children: [
              SizedBox(
                width: screenWidth * 0.4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: const AppImageAsset(
                    image:
                        'https://deeze.net/uploads/20220518081758-6284e3f66645a.jpg',
                    isWebImage: true,
                    webHeight: double.infinity,
                    webFit: BoxFit.fill,
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
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () => setState(() => selectedIndex = index),
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
                            builder: (context) => Container(
                              margin: const EdgeInsets.only(bottom: 60),
                              alignment: Alignment.bottomCenter,
                              child: Card(
                                elevation: 10,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 20),
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
                                          InkWell(
                                            onTap: () {
                                              Navigator.of(context).pop();
                                              setState(
                                                  () => selectedIndex = -1);
                                              Fluttertoast.showToast(
                                                msg: "Item deleted",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.white,
                                                textColor:
                                                    const Color(0XFFA49FAD),
                                                fontSize: 16,
                                              );
                                            },
                                            child: Container(
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 30),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
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
                            ),
                          );
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
