import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ringtone_set/ringtone_set.dart';

class AudioSelectDialog extends StatefulWidget {
  final String file;
  const AudioSelectDialog({Key? key, required this.file}) : super(key: key);

  @override
  State<AudioSelectDialog> createState() => _AudioSelectDialogState();
}

class _AudioSelectDialogState extends State<AudioSelectDialog> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}
  Future<bool> downloadFile(String url) async {
    final appStorage = await getApplicationDocumentsDirectory();
    final file = File("${appStorage.path}/video.mp3");
    try {
      final response = await Dio().get(url,
          options: Options(
              responseType: ResponseType.bytes,
              followRedirects: false,
              receiveTimeout: 0));
      final raf = file.openSync(mode: FileMode.write);
      raf.writeFromSync(response.data);
      raf.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            height: 392,
            width: 306,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: (() {
                    Navigator.of(context).pop();
                  }),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                const SizedBox(
                  height: 23,
                ),
                GestureDetector(
                  onTap: () async {
                    bool success = false;
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    try {
                      success =
                          await RingtoneSet.setRingtoneFromNetwork(widget.file);
                    } on PlatformException {
                      success = false;
                    }
                    var snackBar;
                    if (success) {
                      snackBar = const SnackBar(
                        content: Text("Ringtone set successfully!"),
                      );
                      Navigator.of(context).pop();
                    } else {
                      snackBar = const SnackBar(content: Text("Error"));
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/call_down.png"),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "SET RINGTONE",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 23,
                ),
                GestureDetector(
                  onTap: () async {
                    bool success = false;
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    try {
                      success = await RingtoneSet.setNotificationFromNetwork(
                          widget.file);
                    } on PlatformException {
                      success = false;
                    }
                    var snackBar;
                    if (success) {
                      snackBar = const SnackBar(
                        content: Text("Notifications sound  set successfully!"),
                      );
                      Navigator.of(context).pop();
                    } else {
                      snackBar = const SnackBar(content: Text("Error"));
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/set_notification.png"),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "SET NOTIFICATION",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 23,
                ),
                GestureDetector(
                  onTap: () async {
                    bool success = false;
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    try {
                      success =
                          await RingtoneSet.setAlarmFromNetwork(widget.file);
                    } on PlatformException {
                      success = false;
                    }
                    var snackBar;
                    if (success) {
                      snackBar = const SnackBar(
                        content: Text("Alarm sound  set successfully!"),
                      );
                      Navigator.of(context).pop();
                    } else {
                      snackBar = const SnackBar(content: Text("Error"));
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: Row(
                      children: [
                        Image.asset("assets/alram.png"),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "SET ALARM SOUND",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 23,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 35,
                  ),
                  child: Row(
                    children: [
                      Image.asset("assets/person.png"),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "SET TO CONTACT",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                InkWell(
                  onTap: () async {
                    ProgressDialog pd = ProgressDialog(
                      context,
                      message: Text(
                        "Please Wait!",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.black,
                        ),
                      ),
                    );
                    pd.show();
                    final sucess = await downloadFile(widget.file);
                    var snackBar;
                    if (sucess) {
                      print("sucess");
                      snackBar = const SnackBar(
                        content: Text("Your File  successfully Downloaded"),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 35,
                    ),
                    child: Container(
                        height: 36,
                        // margin: EdgeInsets.only(left: 20),
                        width: 179,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: <Color>[
                                Color(0xFF7209b7),
                                Color(0xFF5c3fcc),
                              ]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "SAVE TO MEDIA",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
