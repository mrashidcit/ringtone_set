import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/widgets/wallpaper_dispaly.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class SingleWallpaper extends StatefulWidget {
  final String urlImage;
  final int index;
  final String userName;
  final String? userProfileUrl;
  const SingleWallpaper(
      {Key? key,
      required this.urlImage,
      required this.index,
      required this.userName,
      this.userProfileUrl})
      : super(key: key);

  @override
  State<SingleWallpaper> createState() => _SingleWallpaperState();
}

class _SingleWallpaperState extends State<SingleWallpaper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0xFF4d047d),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
                Color(0xFF17131F),
              ]),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 60),
              width: double.infinity,
              height: 450,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: widget.urlImage,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      widget.userProfileUrl != null
                          ? CircleAvatar(
                              radius: 15,
                              backgroundImage:
                                  NetworkImage(widget.userProfileUrl!),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 15,
                            ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.userName,
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.arrow_downward,
                          color: Colors.white,
                          size: 13,
                        ),
                        Text(
                          "23k",
                          style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                        context: context,
                        builder: (context) {
                          return WallpaperSelectDialog(file: widget.urlImage);
                        });
                  },
                  child: const Icon(
                    Icons.more_horiz,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  width: 75,
                ),
                Container(
                  height: 37,
                  width: 37,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                  child: const Icon(
                    Icons.add_call,
                    size: 18,
                  ),
                ),
                const SizedBox(
                  width: 75,
                ),
                const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
