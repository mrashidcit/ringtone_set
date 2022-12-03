import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:deeze_app/bloc/deeze_bloc/wallpaper_bloc/wallpaper_bloc.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/helpers/utils.dart';

import 'package:deeze_app/screens/dashboard/dashboard.dart';
import 'package:deeze_app/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_value/shared_value.dart';

import 'bloc/deeze_bloc/Category_bloc/category_bloc.dart';
import 'bloc/deeze_bloc/ringtone_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDZ0kwmgSKX4tYwFpbelQWRgM0cHiamtqg',
      appId: '1:500648108734:android:b1c9a79dc460032e0e34ef',
      messagingSenderId: '500648108734',
      projectId: 'top-aggy',
      // authDomain: '',
      // databaseURL: '',
      // storageBucket: '',
      // measurementId: '',
    ),
  );
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      print('User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  runApp(
    SharedValue.wrapApp(MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? connectivitySubcription;
  ConnectivityResult? connectivityResult;
  String _platformVersion = 'Unknown';
  String __heightWidth = "Unknown";
  @override
  void initState() {
    super.initState();
    initAppState();

    Utils.getSharedValueHelperData();

    _initGoogleMobileAds();
  }

  Future<void> initAppState() async {
    String platformVersion;
    String _heightWidth;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await WallpaperManager.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    try {
      int height = await WallpaperManager.getDesiredMinimumHeight();
      int width = await WallpaperManager.getDesiredMinimumWidth();
      _heightWidth =
          "Width = " + width.toString() + " Height = " + height.toString();
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
      _heightWidth = "Failed to get Height and Width";
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      __heightWidth = _heightWidth;
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RingtoneBloc>(
          create: (BuildContext context) => RingtoneBloc(),
        ),
        BlocProvider<WallpaperBloc>(
          create: (BuildContext context) => WallpaperBloc(),
        ),
        BlocProvider<CategoryBloc>(
          create: (BuildContext context) => CategoryBloc(),
        ),
      ],
      child:
          MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
    );
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    // TODO: Initialize Google Mobile Ads SDK
    return MobileAds.instance.initialize();
  }
}
