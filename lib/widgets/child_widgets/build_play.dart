import 'package:audioplayers/audioplayers.dart';
import 'package:deeze_app/db_services/favorite_database.dart';
import 'package:deeze_app/models/favorite.dart';
import 'package:deeze_app/uitilities/my_theme.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:platform_device_id/platform_device_id.dart';

class BuildPlay extends StatefulWidget {
  final String file;
  final String audioId;
  final String name;
  final String userName;
  final String? userProfileUrl;
  final int index;
  final int activeIndex;
  Duration? duration;
  Duration? position;
  final AudioPlayer audioPlayer;
  bool isPlaying;
  bool isBuffering;
  bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onTapFavourite;
  final Function(double) onChange;

  BuildPlay(
      {Key? key,
      this.duration,
      this.position,
      required this.audioPlayer,
      required this.isPlaying,
      required this.isBuffering,
      required this.audioId,
      required this.onTap,
      required this.onTapFavourite,
      required this.onChange,
      required this.file,
      required this.name,
      required this.index,
      required this.userName,
      this.userProfileUrl,
      required this.isFavourite,
      required this.activeIndex})
      : super(key: key);

  @override
  State<BuildPlay> createState() => _BuildPlayState();
}

class _BuildPlayState extends State<BuildPlay> {
  List<Favorite> favoriteList = [];

  refreshFavorite() async {
    favoriteList = await FavoriteDataBase.instance
        .readAllFavoriteOfCurrentMusic(widget.audioId);
    setState(() {});
  }

  List myGradientList = const [
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF289987),
        Color(0xFF727b64),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5951af),
        Color(0xFF5f5b8c),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5d8897),
        Color(0xFF4f4d7e),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF5048dd),
        Color(0xFF89c0d3),
      ],
    ),
    LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [
        Color(0xFF5952af),
        Color(0xFF5e5b8c),
      ],
    ),
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    refreshFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: widget.activeIndex == widget.index ? 254 : 0,
        thumbShape: SliderComponentShape.noOverlay,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: SliderComponentShape.noOverlay,
        trackShape: const RectangularSliderTrackShape(),
      ),
      child: Container(
        height: 254,
        width: 254,
        decoration: BoxDecoration(
          gradient: (widget.index % 4 == 0)
              ? myGradientList[0]
              : (widget.index % 3 == 0)
                  ? myGradientList[3]
                  : (widget.index % 2 == 0)
                      ? myGradientList[4]
                      : myGradientList[1],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            Slider(
              activeColor: Colors.white12,
              inactiveColor: Colors.transparent,
              min: 0,
              max: widget.duration!.inMicroseconds.toDouble(),
              value: (widget.position!.inMilliseconds.toDouble() <=
                      widget.duration!.inMilliseconds.toDouble())
                  ? widget.position!.inMicroseconds.toDouble()
                  : widget.duration!.inMilliseconds.toDouble(),
              onChanged: (value) async {
                // widget.onChange(value);
              },
            ),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                  // color: MyTheme.orange,
                  borderRadius: BorderRadius.circular(6)),
            ),
            GestureDetector(
              onTap: widget.onTap,
              child: Align(
                alignment: Alignment.center,
                child: buildPlayAndPauseButtonContainer(),
              ),
            ),
            Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: (() async {
                    String? deviceId = await PlatformDeviceId.getDeviceId;
                    Favorite favorite = Favorite(
                        name: widget.name,
                        currentDeviceId: deviceId!,
                        path: widget.file,
                        deezeId: widget.audioId,
                        type: "MUSIC");
                    favoriteList.isEmpty
                        ? await FavoriteDataBase.instance.addFavorite(favorite)
                        : await FavoriteDataBase.instance
                            .delete(favoriteList.first.deezeId);
                    refreshFavorite();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 15, right: 15),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: favoriteList.isEmpty
                          ? const AppImageAsset(
                              image: 'assets/favourite.svg', height: 16)
                          : const AppImageAsset(
                              image: "assets/favourite_fill.svg",
                              color: Colors.red,
                              height: 16,
                              width: 16,
                            ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget buildPlayAndPauseButtonContainer() {
    if (widget.isBuffering) {
      return const SizedBox(
        child: LoadingPage(),
        height: 28,
        width: 28,
      );
    } else {
      return AppImageAsset(
        image: widget.isPlaying ? 'assets/pause.svg' : 'assets/play.svg',
        height: 90,
      );
    }
  }
}
