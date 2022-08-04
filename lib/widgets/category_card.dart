import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/widgets/wallpaper_dispaly.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../models/deeze_model.dart';

class CategoryCard extends StatelessWidget {
  final List<HydraMember>? listHydra;
  final int? index;
  final bool iscategory;
  final image;
  final name;
  const CategoryCard(
      {Key? key,
      this.image,
      this.name,
      this.listHydra,
      this.index,
      this.iscategory = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: image,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
  }
}
