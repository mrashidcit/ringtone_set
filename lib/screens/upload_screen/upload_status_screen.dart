import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadSuccess extends StatelessWidget {
  const UploadSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.26),
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            height: 350,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppImageAsset(image: 'assets/upload_done.svg'),
                const SizedBox(height: 20),
                Text(
                  'Upload',
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0xff17131F),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    wordSpacing: 0.34,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'File Upload Success',
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0xffA49FAD),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    wordSpacing: 0.34,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Home',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0XFF7209B7),
                              Color(0XFF5945CE),
                            ],
                          ),
                        ),
                        child: Text(
                          'Upload',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UploadFail extends StatelessWidget {
  const UploadFail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.26),
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Container(
            height: 350,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppImageAsset(image: 'assets/upload_fail.svg'),
                const SizedBox(height: 20),
                Text(
                  'File Error',
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0xff17131F),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    wordSpacing: 0.34,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Maximum File Upload : 2Mb',
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0xffA49FAD),
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    wordSpacing: 0.34,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Home',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0XFF7209B7),
                              Color(0XFF5945CE),
                            ],
                          ),
                        ),
                        child: Text(
                          'Retry',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
