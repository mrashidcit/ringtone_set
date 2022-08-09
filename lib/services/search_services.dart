import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/deeze_model.dart';
import '../uitilities/end_points.dart';

class SearchServices {
  Future<List<HydraMember>> searchRingtone(String query) async {
    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
      "enabled": "true",
      "type": "RINGTONE",
      "name": query
    });

    http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print('${response.statusCode} : ${response.request}');

    if (response.statusCode == 200) {
      print(response.body);
      var rawResponse = deezeFromJson(response.body);
      return rawResponse.hydraMember!;
    } else {
      throw Exception();
    }
  }

  Future<List<HydraMember>> search(String query) async {
    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
      "enabled": "true",
      "name": query
    });

    http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print('${response.statusCode} : ${response.request}');

    if (response.statusCode == 200) {
      print(response.body);
      var rawResponse = deezeFromJson(response.body);
      return rawResponse.hydraMember!;
    } else {
      throw Exception();
    }
  }

  Future<List<HydraMember>> searchWallpers(String query) async {
    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
      "enabled": "true",
      "type": "WALLPAPER",
      "name": query
    });

    http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print('${response.statusCode} : ${response.request}');

    if (response.statusCode == 200) {
      print(response.body);
      var rawResponse = deezeFromJson(response.body);
      return rawResponse.hydraMember!;
    } else {
      throw Exception();
    }
  }
}
