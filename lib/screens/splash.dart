import 'dart:async';

import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isCheckInternet = false;

  @override
  void initState() {
    super.initState();
    InternetConnectionChecker().onStatusChange.listen((status) {
      final hasInternet = status == InternetConnectionStatus.connected;
      if (hasInternet) {
        Timer(const Duration(seconds: 5), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const Dashbaord(
                type: "RINGTONE",
              ),
            ),
          );
        });
      } else {
        showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => const InternetCheckerDialog(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4d047d),
      body: Stack(
        alignment: Alignment.center,
        children: [
          const AppImageAsset(
            image: 'assets/splash_back.png',
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              const AppImageAsset(image: 'assets/app_logo.svg'),
              const SizedBox(height: 12),
              Text(
                'Ringtones & Wallpapers',
                style: GoogleFonts.archivo(
                  fontStyle: FontStyle.normal,
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(),
              const LoadingPage(),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}
