import 'package:deeze_app/screens/auth/login.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_social_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> {
  @override
  Widget build(BuildContext context) {
    print('Current screen --> $runtimeType');
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0xFF4d047d),
                  Color(0xFF4d047d),
                  Color(0xFF17131F),
                  Color(0xFF17131F),
                  Color(0xFF17131F),
                  Color(0xFF17131F),
                  Color(0xFF17131F),
                ],
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              children: [
                const Spacer(),
                const SizedBox(height: 10),
                const AppImageAsset(image: 'assets/app_logo.svg'),
                const SizedBox(height: 38),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'pimp your Android device with top ringtones and new wallpapers.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.archivo(
                      color: Colors.white,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 70),
                AppSocialMediaButton(
                    image: 'assets/google.svg',
                    color: Color(0XFF0764E3),
                    text: 'Google',
                    onTap: () {}),
                const SizedBox(height: 20),
                AppSocialMediaButton(
                    image: 'assets/facebook.svg',
                    color: Color(0XFF4267B2),
                    text: 'Facebook',
                    onTap: () {}),
                const SizedBox(height: 20),
                AppSocialMediaButton(
                  color: Colors.white,
                  text: 'e-mail',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Login()),
                  ),
                ),
                const SizedBox(height: 36),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New here?    Sign Up",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.archivo(
                          color: Colors.white,
                          fontStyle: FontStyle.normal,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
