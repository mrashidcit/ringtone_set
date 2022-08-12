import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSocialMediaButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String image;
  final String? text;
  final Color? color;

  const AppSocialMediaButton(
      {Key? key, this.text, this.onTap, this.image = '', this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF303030).withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (image.isNotEmpty) AppImageAsset(image: image),
            if (image.isNotEmpty) const SizedBox(width: 30),
            Text(
              'Log in with $text',
              style: GoogleFonts.archivo(
                color: image.isEmpty ? Colors.black : Colors.white,
                fontStyle: FontStyle.normal,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
