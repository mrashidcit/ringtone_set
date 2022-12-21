import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppImageAsset extends StatelessWidget {
  final String? image;
  final bool isWebImage;
  final double? height;
  final double? webHeight;
  final double? width;
  final double? webWidth;
  final Color? color;
  final BoxFit? fit;
  final BoxFit webFit;

  const AppImageAsset({
    Key? key,
    @required this.image,
    this.webFit = BoxFit.cover,
    this.fit,
    this.height,
    this.webHeight,
    this.width,
    this.webWidth,
    this.color,
    this.isWebImage = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print(
    //     '>> AppImageAsset - build : height , width , image = $height , $width , $image');
    return isWebImage
        ? CachedNetworkImage(
            imageUrl: image!,
            height: webHeight,
            width: webWidth,
            fit: webFit,
            placeholder: (context, url) => const SizedBox(
              height: 20,
              width: 20,
              child: LoadingPage(),
            ),
            errorWidget: (context, url, error) => const AppImageAsset(
              image: 'assets/app_logo.svg',
              fit: BoxFit.contain,
            ),
          )
        : image!.split('.').last != 'svg'
            ? buildImageFromAssetOrFile()
            : SvgPicture.asset(
                image!,
                height: height,
                width: width,
                color: color,
              );
  }

  Image buildImageFromAssetOrFile() {
    return image!.contains('assets')
        ? Image.asset(
            image!,
            fit: fit,
            height: height,
            width: width,
            color: color,
          )
        : Image.file(
            File(image!),
            fit: fit,
            height: height,
            width: width,
            color: color,
          );
  }
}
