import 'package:deeze_app/screens/auth/login.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_social_login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => OnboardingState();
}

class OnboardingState extends State<Onboarding> {
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
          ListView(
            primary: true,
            physics: const BouncingScrollPhysics(),
            padding:
            const EdgeInsets.symmetric(horizontal: 35).copyWith(top: 100),
            children: [
              const AppImageAsset(image: 'assets/app_logo.svg'),
              const SizedBox(height: 34),
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
              const SizedBox(height: 40),
              const AppSocialMediaButton(image: 'assets/google.svg',color: Color(0XFF0764E3), text: 'Google'),
              const SizedBox(height: 20),
              const AppSocialMediaButton(image: 'assets/facebook.svg',color: Color(0XFF4267B2), text: 'Facebook'),
              const SizedBox(height: 20),
              AppSocialMediaButton(
                color: Colors.white,
                text: 'e-mail',
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const Login()),
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'New here?  Sign up',
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
