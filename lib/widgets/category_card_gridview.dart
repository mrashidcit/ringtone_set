import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/wallpaper_dispaly.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:transparent_image/transparent_image.dart';

import '../db_services/favorite_database.dart';
import '../models/deeze_model.dart';
import '../models/favorite.dart';

class CategoryCard extends StatelessWidget {
  final List<DeezeItemModel>? listHydra;
  final int? index;
  final bool iscategory;
  final String id;
  final VoidCallback? onRefresh;
  final image;
  final name;
  CategoryCard(
      {Key? key,
      this.image,
      this.onRefresh,
      this.name,
      this.listHydra,
      required this.id,
      this.index,
      this.iscategory = false})
      : super(key: key);
  List<Favorite> favoriteList = [];
  // refreshFavorite() async {
  //   favoriteList =
  //       await FavoriteDataBase.instance.readAllFavoriteOfCurrentMusic(id);
  // }

  @override
  Widget build(BuildContext context) {
    // refreshFavorite();
    double screenWidth = MediaQuery.of(context).size.width;
    return image == ""
        ? Container(
            width: screenWidth * 0.4,
            decoration: BoxDecoration(
              image: const DecorationImage(
                  image: AssetImage(
                    "assets/no_image.jpg",
                  ),
                  fit: BoxFit.fill),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: (() {
              iscategory
                  ? null
                  : Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WallPaperSlider(
                          listHydra: listHydra,
                          index: index,
                        ),
                      ),
                    );
            }),
            child: SizedBox(
              width: screenWidth * 0.4,
              child: Stack(
                children: [
                  SizedBox(
                    width: screenWidth * 0.4,
                    height: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AppImageAsset(
                        image: image,
                        isWebImage: true,
                        webFit: BoxFit.cover,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (() async {
                      String? deviceId = await PlatformDeviceId.getDeviceId;

                      await FavoriteDataBase.instance.delete(id);

                      iscategory ? onRefresh!() : null;
                    }),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: AppImageAsset(
                          image: "assets/favourite_fill.svg",
                          color: Colors.red,
                          height: 16,
                          width: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}
