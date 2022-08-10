// ignore_for_file: unnecessary_new

import 'package:deeze_app/screens/profile_screen/profile_screen.dart';
import 'package:deeze_app/screens/upload_screen/upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../screens/screens.dart';
import 'elevated_button_widget.dart';

class MyDrawerHeader extends StatefulWidget {
  MyDrawerHeader({Key? key}) : super(key: key);

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
      color: const Color(0xFF4d047d),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo.png",
                width: 90,
              ),
              const SizedBox(
                height: 50,
              ),
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
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (contex) => Login()));
                  },
                ),
              ),
            ],
          ),
          SizedBox(
            width: screenWidth * 0.1,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen(),));
                },
                child: Image.asset(
                  "assets/Oval.png",
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SizedBox(
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
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UploadScreen(),));
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
