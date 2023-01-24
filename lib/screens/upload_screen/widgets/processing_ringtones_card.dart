import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/db_services/favorite_database.dart';
import 'package:deeze_app/models/favorite.dart';
import 'package:deeze_app/uitilities/constants.dart';
import 'package:deeze_app/uitilities/my_theme.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_share/social_share.dart';

import '../../../models/deeze_model.dart';

class ProcessingRingtonesCard extends StatefulWidget {
  final VoidCallback onNavigate;
  ProcessingRingtonesCard({
    Key? key,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<ProcessingRingtonesCard> createState() => _RingtonesCardState();
}

class _RingtonesCardState extends State<ProcessingRingtonesCard> {
  // late AnimationController controller;
  List mygradientList = const [
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF289987),
          Color(0xFF727b64),
        ]),
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF5951af),
          Color(0xFF5f5b8c),
        ]),
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF5d8897),
          Color(0xFF4f4d7e),
        ]),
    LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF5048dd),
          Color(0xFF89c0d3),
        ]),
    LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [
          Color(0xFF5952af),
          Color(0xFF5e5b8c),
        ]),
  ];
  final _random = Random();
  bool _visible = true;
  double _width = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    var element = mygradientList[_random.nextInt(mygradientList.length)];

    return InkWell(
      onTap: widget.onNavigate,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          // height: 70,
          height: double.infinity,
          width: screenWidth,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/processing_card_background.png'),
                fit: BoxFit.fill),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              Center(
                child: AppImageAsset(
                  image: 'assets/sand-clock.png',
                  height: Constants.sandbox_height,
                ),
              ),
              Positioned(
                  bottom: 4,
                  left: 2,
                  child: Text(
                    'Processing ...',
                    style: TextStyle(color: MyTheme.white),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
