// ignore_for_file: unnecessary_new

import 'package:deeze_app/screens/profile_screen/profile_screen.dart';
import 'package:deeze_app/screens/upload_screen/upload_screen.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/material.dart';
import '../screens/screens.dart';
import 'elevated_button_widget.dart';

class MyDrawerHeader extends StatefulWidget {
  const MyDrawerHeader({Key? key}) : super(key: key);

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
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
                child: const AppImageAsset(image: 'assets/dummy_profile_pic.svg', height: 70),
              ),
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
                  labelText: 'Login',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.white,
                  fontWeight: FontWeight.w400,
                  textSize: 15,
                  padding: 0,
                  borderRadius: 15,
                  borderColor: Colors.white,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
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
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UploadScreen(),
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
