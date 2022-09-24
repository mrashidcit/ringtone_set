import 'package:deeze_app/models/search_model.dart';
import 'package:deeze_app/models/trending_search_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/deeze_model.dart';
import '../uitilities/end_points.dart';

class SearchServices {
  List<String> trendingSearchItems = [];

  Future<List<SearchModel>> searchRingtone(String query) async {
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

      List<SearchModel> rawResponse = searchModelFromJson(response.body);

      return query.isEmpty ? [] : rawResponse;
    } else {
      throw Exception();
    }
  }

  Future<List<SearchModel>> search(String query) async {
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
      List<SearchModel> rawResponse = searchModelFromJson(response.body);

      return query.isEmpty ? [] : rawResponse ;
    } else {
      throw Exception();
    }
  }

  Future<List<SearchModel>> searchWallpapers(String query) async {
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

      List<SearchModel> rawResponse = searchModelFromJson(response.body);

      return query.isEmpty ? [] : rawResponse;
    } else {
      throw Exception();
    }
  }

  Future<void> trendingSearch() async {
    var url = '$getDeezeAppUrlContent/search/trending';

    print("==> url = $url");

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
    });

    http.Response response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    print('==>${response.statusCode} : ${response.request}');

    if (response.statusCode == 200) {
      print(response.body);

      TrendingSearchModel? rawResponse = trendingSearchModelFromJson(response.body);

      print("===>${rawResponse.trendingTerms}");

      if(rawResponse.trendingTerms != null && rawResponse.trendingTerms!.isNotEmpty){
        for (TrendingSearch element in rawResponse.trendingTerms!) {
          trendingSearchItems.add(element.trendingName!);
        }
      }
      
    } else {
      throw Exception();
    }
  }

}
