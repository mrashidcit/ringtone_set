// ignore_for_file: unnecessary_new

import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/screens/profile_screen/profile_screen.dart';
import 'package:deeze_app/screens/upload_screen/upload_screen.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/screens.dart';
import 'elevated_button_widget.dart';

class MyDrawerHeader extends StatefulWidget {
  final bool showProfile;
  final bool showUpload;
  const MyDrawerHeader(
      {Key? key, this.showProfile = true, this.showUpload = true})
      : super(key: key);

  @override
  State<MyDrawerHeader> createState() => _MyDrawerHeaderState();
}

class _MyDrawerHeaderState extends State<MyDrawerHeader> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      height: 200,
      width: double.infinity,
      alignment: Alignment.center,
      color: const Color(0xFF4d047d),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              const AppImageAsset(image: "assets/app_logo.svg", width: 90),
              const Spacer(flex: 2),
              is_logged_in.$
                  ? GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        if (widget.showProfile) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) => const ProfileScreen()),
                          );
                        }
                      },
                      child: const AppImageAsset(
                          image: 'assets/dummy_profile_pic.svg', height: 70),
                    )
                  : Container(),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              SizedBox(
                height: 30,
                width: screenWidth * 0.25,
                child: ElevateButtonWidget(
                  labelText: is_logged_in.$ ? 'Logout' : 'Login',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  fontWeight: FontWeight.w400,
                  textSize: 15,
                  padding: 0,
                  borderRadius: 15,
                  borderColor: Colors.white,
                  onPressed: is_logged_in.$ ? performLogout : openLoginScreen,
                ),
              ),
              const Spacer(flex: 2),
              is_logged_in.$
                  ? SizedBox(
                      height: 30,
                      width: screenWidth * 0.25,
                      child: ElevateButtonWidget(
                        icon: true,
                        labelText: 'Upload',
                        textColor: Colors.white,
                        backgroundColor: const Color(0xFFFF6411),
                        foregroundColor: const Color(0xFFFF6411),
                        fontWeight: FontWeight.w400,
                        textSize: 15,
                        padding: 0,
                        borderRadius: 15,
                        borderColor: const Color(0xFFFF6411),
                        onPressed: () {
                          Scaffold.of(context).closeDrawer();
                          if (widget.showUpload) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const UploadScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  : Container(),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  void openLoginScreen() {
    {
      Scaffold.of(context).closeDrawer();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const OnBoarding()),
      );
    }
  }

  void performLogout() async {
    // Clear Cache Values
    is_logged_in.$ = false;
    user_id.$ = 0;
    api_token.$ = '';

    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Dashbaord(type: ItemType.RINGTONE.name),
      ),
      (route) => false,
    );
  }
}
