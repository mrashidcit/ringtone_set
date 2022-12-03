import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/helpers/utils.dart';
import 'package:deeze_app/repositories/auth_repository.dart';
import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => LoginState();
}

class LoginState extends State<Login> {
  bool obscureText = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
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
              TextFormField(
                controller: emailController,
                style: GoogleFonts.archivo(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'e-mail',
                  hintStyle: GoogleFonts.archivo(
                    color: const Color(0XFF929292),
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                style: GoogleFonts.archivo(
                  color: Colors.black,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                obscureText: obscureText,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  hintText: 'Password',
                  hintStyle: GoogleFonts.archivo(
                    color: const Color(0XFF929292),
                    fontStyle: FontStyle.normal,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 2),
                  suffixIcon: InkWell(
                    onTap: () => passwordText(),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 5, 5, 0),
                      child: AppImageAsset(
                        image: obscureText
                            ? 'assets/visible_on.svg'
                            : 'assets/visible_off.svg',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _showProgressBar
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RefreshProgressIndicator(),
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      const Color(0xFF560CAD),
                    ),
                  ),
                  child: Text(
                    'Log in',
                    style: GoogleFonts.archivo(
                      color: const Color(0XFFFFFFFF),
                      fontStyle: FontStyle.normal,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: performSignInAction,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'Forgot password?',
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  color: Colors.white,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'By log in you agree with our',
                textAlign: TextAlign.center,
                style: GoogleFonts.archivo(
                  color: const Color(0XFF929292),
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Terms of service',
                  style: GoogleFonts.archivo(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  children: const <InlineSpan>[
                    TextSpan(
                      text: ' and ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0XFF929292),
                      ),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void passwordText() => setState(() => obscureText = !obscureText);

  Future<void> performSignInAction() async {
    var email = emailController.text.trim();
    var password = passwordController.text.trim();

    Utils.hideKeyboard();

    if (email.isEmpty || password.isEmpty) {
      var snackBar = SnackBar(
        content: Text('Fill All Required Fields!'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

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
