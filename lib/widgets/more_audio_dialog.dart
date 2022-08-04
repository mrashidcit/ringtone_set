import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoreAudioDialog extends StatelessWidget {
  final String file;
  final String fileName;
  final String userName;
  final String userImage;
  const MoreAudioDialog(
      {Key? key,
      required this.file,
      required this.userName,
      required this.userImage,
      required this.fileName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: SizedBox(
          height: 173,
          width: 318,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$fileName",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(
                        Icons.flag_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 16,
                    child: ListView.builder(
                        itemCount: 3,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                                color: Color(0xFFA49FAD),
                                borderRadius: BorderRadius.circular(3)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 13),
                              child: Text(
                                "Love",
                                style: GoogleFonts.archivo(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      userImage != null
                          ? CircleAvatar(
                              radius: 15,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(
                                userImage,
                              ),
                            )
                          : const CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 15,
                            ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        userName,
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Color(0xFFA49FAD),
                          fontSize: 15,
                          wordSpacing: -0.05,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
