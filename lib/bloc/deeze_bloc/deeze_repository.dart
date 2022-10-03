import 'package:deeze_app/bloc/deeze_bloc/wallpaper_bloc/wallpaper_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/models.dart';
import '../../uitilities/end_points.dart';
import 'ringtone_state.dart';

class DeezeRepository {
  Future<RingtoneState> getRingtone() async {
    var url = getDeezeAppHpUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
      // "enabled": "true",
      "type": "RINGTONE"
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeItemModelFromJson(response.body);
        return LoadedRingtone(deeze: rawResponse);
      } else {
        return const RingtoneError();
      }
    } catch (e) {
      return const RingtoneError();
    }
  }

  Future<WallpaperState> getWallPapers() async {
    var url = getDeezeAppHpUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
      // "enabled": "true",
      "type": "WALLPAPER"
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeItemModelFromJson(response.body);
        return WallpaperLoaded(deeze: rawResponse);
      } else {
        return WallpaperError();
      }
    } catch (e) {
      return WallpaperError();
    }
  }
}
