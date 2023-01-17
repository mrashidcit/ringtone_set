import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/helpers/utils.dart';
import 'package:deeze_app/repositories/auth_repository.dart';
import 'package:deeze_app/screens/auth/login.dart';
import 'package:deeze_app/screens/auth/sign_up.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_social_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => OnBoardingState();
}

class OnBoardingState extends State<OnBoarding> {
  bool _showProgressBar = false;

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
                _showProgressBar
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RefreshProgressIndicator(),
                        ],
                      )
                    : Container(),
                const SizedBox(height: 20),
                AppSocialMediaButton(
                  image: 'assets/google.svg',
                  color: Color(0XFF0764E3),
                  text: 'Google',
                  onTap: () async {
                    UserCredential userCredentials = await signInWithGoogle();

                    setState(() {
                      _showProgressBar = true;
                    });

                    var firstName = userCredentials.user!.displayName!;
                    var lastName = userCredentials.user!.displayName!;
                    var email = userCredentials.user!.email!;
                    var googleId = userCredentials.credential!.providerId!;
                    var imageUrl = userCredentials.user!.photoURL!;

                    var signUpResponse =
                        await AuthRepository().getSignUpWithGoogleResponse(
                      firstName,
                      lastName,
                      email,
                      googleId,
                      imageUrl,
                    );

                    print(
                        '>> signUpResponse.result : ${signUpResponse.result}');
                    if (signUpResponse.result) {
                      // performSignInAction(email, password);

                      saveUserInCache(signUpResponse.user!);
                      api_token.$ = signUpResponse.apiToken;
                      is_logged_in.$ = true;

                      var snackBar = SnackBar(
                        content: Text('Successfully Logged In!'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                Dashbaord(type: ItemType.RINGTONE.name),
                          ),
                          (route) => false);
                    } else {
                      // performSignInAction(email, password);
                      // is_logged_in.$ = false;
                      // user_id.$ = 0;
                      var snackBar = SnackBar(
                        content: Text(signUpResponse.message),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                    setState(() {
                      _showProgressBar = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                AppSocialMediaButton(
                    image: 'assets/facebook.svg',
                    color: Color(0XFF4267B2),
                    text: 'Facebook',
                    onTap: () async {
                      UserCredential userCredentials =
                          await signInWithFacebook();

                      setState(() {
                        _showProgressBar = true;
                      });

                      var firstName = userCredentials.user!.displayName!;
                      var lastName = '';
                      var email = userCredentials.user!.email!;
                      var facebookId =
                          userCredentials.additionalUserInfo!.providerId!;
                      var imageUrl = userCredentials.user!.photoURL!;

                      var signUpResponse =
                          await AuthRepository().getSignUpWithFacebookResponse(
                        firstName,
                        lastName,
                        email,
                        facebookId,
                        imageUrl,
                      );

                      if (signUpResponse.result) {
                        saveUserInCache(signUpResponse.user!);
                        api_token.$ = signUpResponse.apiToken;
                        is_logged_in.$ = true;

                        var snackBar = SnackBar(
                          content: Text('Successfully Logged In!'),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) =>
                                  Dashbaord(type: ItemType.RINGTONE.name),
                            ),
                            (route) => false);
                      } else {
                        // performSignInAction(email, password);
                        // is_logged_in.$ = false;
                        // user_id.$ = 0;
                        var snackBar = SnackBar(
                          content: Text(signUpResponse.message),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                      setState(() {
                        _showProgressBar = false;
                      });
                    }),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (ctx) => SignUp()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("New here?    Sign Up",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.archivo(
                              color: Colors.white,
                              fontStyle: FontStyle.normal,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 5,
                    // ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
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

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    print(">> signInWithFacebook");
    // Trigger the sign-in flow
    // final LoginResult loginResult = await FacebookAuth.instance.login();
    final LoginResult loginResult =
        await FacebookAuth.instance.login(permissions: const ['email']);

    print(">> signInWithFacebook - status : ${loginResult.status.name}");
    print(">> signInWithFacebook - message : ${loginResult.message}");
    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.token);

    // Once signed in, return the UserCredential
    return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  Future<void> performSignInAction(email, password) async {
    setState(() {
      _showProgressBar = true;
    });

    var loginResponse =
        await AuthRepository().getSignInUserResponse(email, password);

    if (loginResponse.result) {
      saveUserInCache(loginResponse.user);
      api_token.$ = loginResponse.api_token;
      is_logged_in.$ = true;

      await Utils.getSharedValueHelperData();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (ctx) => Dashbaord(type: ItemType.RINGTONE.name)),
        (route) => false,
      );
    } else {
      var snackBar = SnackBar(
        content: Text(loginResponse.message),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      _showProgressBar = false;
    });
  }
}
