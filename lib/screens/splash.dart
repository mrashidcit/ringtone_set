import 'dart:async';

import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

import 'screens.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isCheckInternet = false;
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const Dashbaord(
            type: "RINGTONE",
          ),
        ),
      );
    });
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (hasInternet) {
      } else {
        showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return InternetCheckorDialog();
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4d047d),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo.png",
            ),
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              "assets/Ringtones_Wallpape.png",
            ),
            const SizedBox(
              height: 50,
            ),
            const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
