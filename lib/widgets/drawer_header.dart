// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';

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
              Image.asset(
                "assets/Oval.png",
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
                    labelText: 'upload',
                    backgroundColor: Color(0xFFFF6411),
                    foregroundColor: Color(0xFFFF6411),
                    fontWeight: FontWeight.w400,
                    textSize: 15,
                    padding: 0,
                    borderRadius: 15,
                    borderColor: Color(0xFFFF6411),
                    onPressed: () {},
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
