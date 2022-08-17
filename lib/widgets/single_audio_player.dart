import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ndialog/ndialog.dart';
import 'package:ringtone_set/ringtone_set.dart';

class BuildPlay extends StatefulWidget {
  final String file;
  final String name;
  final String userName;
  final String? userProfileUrl;
  final int index;
  const BuildPlay(
      {Key? key,
      required this.file,
      required this.name,
      required this.index,
      required this.userName,
      this.userProfileUrl})
      : super(key: key);

  @override
  State<BuildPlay> createState() => _BuildPlayState();
}

class _BuildPlayState extends State<BuildPlay> {
  final audioPlayer = AudioPlayer();

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    liseten(); // audioPlayer.onDurationChanged.listen((state) {
    //   setState(() {
    //     duration = state;
    //   });
    // });
    // audioPlayer.onAudioPositionChanged.listen((state) {
    //   setState(() {
    //     position = state;
    //   });
    // });
  }

  void liseten() async {
    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.PLAYING;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    audioPlayer.dispose();
    isPlaying = false;
    PlayerState.STOPPED;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
              Text(
                widget.name,
                style: GoogleFonts.archivo(
                  fontStyle: FontStyle.normal,
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                height: 400,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[
                        Color(0xFF9f5c96),
                        Color(0xFF93b1b9),
                      ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (() async {
                        if (isPlaying) {
                          await audioPlayer.pause();
                        } else {
                          await audioPlayer.play(widget.file);
                        }
                      }),
                      child: Container(
                        height: 50,
                        width: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFa28eac),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white),
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Slider(
              //   min: 0,
              //   max: duration.inSeconds.toDouble(),
              //   value: position.inSeconds.toDouble(),
              //   onChanged: onChanged,
              // ),
              // Row(children: [
              //   Text(formatTime())
              // ],)
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
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
                                fontStyle: FontStyle.normal,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (context) {
                            return AudioSelectDialog(file: widget.file);
                          });
                    },
                    child: const Icon(
                      Icons.more_horiz,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 60,
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
                    width: 60,
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
      ),
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.26),
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 180,
                    alignment: Alignment.centerLeft,
                    child: const AppImageAsset(
                      image: 'assets/bakward_arrow.svg',
                      height: 20,
                    ),
                  ),
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
                      success = await RingtoneSet.setRingtoneFromNetwork(
                          widget.file);
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
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/call_drop.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET RINGTONE',
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
                const SizedBox(height: 22),
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
                        content:
                            Text("Notifications sound  set successfully!"),
                      );
                      Navigator.of(context).pop();
                    } else {
                      snackBar = const SnackBar(content: Text("Error"));
                      Navigator.of(context).pop();
                    }
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/notification.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET NOTIFICATION',
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
                const SizedBox(height: 22),
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
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/bell_clock.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET ALARM SOUND',
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
                const SizedBox(height: 22),
                Container(
                  width: 180,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                        child: AppImageAsset(
                          image: 'assets/person.svg',
                          height: 20,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        'SET TO CONTACT',
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
                const SizedBox(height: 30),
                InkWell(
                  onTap: () {},
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 50,
                        width: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[
                              Color(0xFF7209b7),
                              Color(0xFF5c3fcc),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppImageAsset(image: 'assets/save_down.svg', height: 14),
                            const SizedBox(width: 20),
                            Text(
                              'SAVE TO MEDIA',
                              style: GoogleFonts.archivo(
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: -6,
                        right: -10,
                        child: AppImageAsset(image: 'assets/premium_badge.svg'),
                      ),
                    ],
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
