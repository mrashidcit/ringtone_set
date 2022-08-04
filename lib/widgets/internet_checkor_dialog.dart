import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InternetCheckorDialog extends StatelessWidget {
  const InternetCheckorDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 310,
        width: 300,
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/wifi.png"),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "No internet connection",
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Cannot reach our servers",
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0xFFA49FAD),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Exit",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        height: 35,
                        width: 108,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              // begin: Alignment.centerLeft,
                              // end: Alignment.centerRight,
                              colors: [
                                Color(0xFF7209B7),
                                Color(0xFF5945CE),
                              ]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Retry",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
