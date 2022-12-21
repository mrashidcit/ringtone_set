import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/repositories/auth_repository.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/screens/web_view/show_web_page.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _showProgressForDeleteRequest = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF252030),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Row(
              children: [
                AppImageAsset(image: "assets/app_logo.svg", width: 90),
                Expanded(child: SizedBox()),
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: AppImageAsset(
                        image: 'assets/menu.svg',
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            Text(
              'Terms and Policies',
              style: GoogleFonts.archivo(
                fontStyle: FontStyle.normal,
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ShowWebPage(
                            url:
                                'https://sites.google.com/view/aggyapps/privacy-policy',
                            title: 'Content Policy',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(
                        'Content Policy',
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ShowWebPage(
                            url:
                                'https://sites.google.com/view/aggyapps/privacy-policy',
                            title: 'Terms and Services',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Terms and Services',
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
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
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => ShowWebPage(
                            url:
                                'https://sites.google.com/view/aggyapps/privacy-policy',
                            title: 'DMCA',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Text(
                        'DMCA',
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 25),
            Text(
              'Account Settings',
              style: GoogleFonts.archivo(
                fontStyle: FontStyle.normal,
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      // Clear Cache Values
                      is_logged_in.$ = false;
                      user_id.$ = 0;
                      api_token.$ = '';

                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Dashbaord(type: ItemType.RINGTONE.name),
                        ),
                        (route) => false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 4, right: 10, top: 6, bottom: 6),
                      child: Text(
                        'Log out',
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _showProgressForDeleteRequest = true;
                      });

                      await AuthRepository().getDeleteUserAccountResponse();

                      // Clear Cache Values
                      is_logged_in.$ = false;
                      user_id.$ = 0;
                      api_token.$ = '';

                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              Dashbaord(type: ItemType.RINGTONE.name),
                        ),
                        (route) => false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      // child: Text(
                      //   'Delete Account',
                      //   style: GoogleFonts.archivo(
                      //     fontStyle: FontStyle.normal,
                      //     color: Colors.red,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      child: _showProgressForDeleteRequest
                          ? RefreshProgressIndicator()
                          : Text(
                              'Delete Account',
                              style: GoogleFonts.archivo(
                                fontStyle: FontStyle.normal,
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Divider(color: Colors.grey, height: 1),
            const SizedBox(height: 25),
            Row(
              children: [
                SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'About Deeze',
                    style: GoogleFonts.archivo(
                      fontStyle: FontStyle.normal,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
