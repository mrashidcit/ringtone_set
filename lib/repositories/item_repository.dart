import 'dart:async';
import 'dart:convert';

import 'package:deeze_app/app_config.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/delete_user_response.dart';
import 'package:deeze_app/models/file_upload_response.dart';
import 'package:deeze_app/models/item_create_response.dart';
import 'package:deeze_app/models/item_delete_response.dart';
import 'package:deeze_app/models/random_item_response.dart';
import 'package:deeze_app/models/signin_response.dart';
import 'package:deeze_app/models/signup_response.dart';
import 'package:deeze_app/models/user_profile_update_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class ItemRepository {
  Future<ItemCreateResponse> getCreateItemResponse({
    required String title,
    required List<String> tags,
    required ItemType itemType,
    required String uploadedFileName,
  }) async {
    var post_body = jsonEncode({
      "name": "$title",
      "type": itemType.name,
      "file": "$uploadedFileName",
      "user": {
        "id": user_id.$,
      },
      "categories": {
        "id": 0,
      },
      "tags": [
        ...tags.map<Map<String, String>>((e) => {"value": e})
      ],
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/items");
    print('>> getCreateItemResponse - url : $url');
    print('>> getCreateItemResponse - post_body : $post_body');
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "x-api-token": api_token.$,
        },
        body: post_body);

    var itemCreateResponse = ItemCreateResponse();

    print(
        '>> getCreateItemResponse - response , statusCode : ${response.body} , ${response.statusCode}');
    if (response.statusCode == 201) {
      itemCreateResponse = itemCreateResponseFromJson(response.body);
    }

    return itemCreateResponse;
  }

  Future<ItemDeleteResponse> getDeleteItemResponse({
    required int itemId,
  }) async {
    var post_body = jsonEncode({});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/items/$itemId");
    final response = await http.delete(url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "x-api-token": api_token.$,
        },
        body: post_body);

    var outputResponse = ItemDeleteResponse();

    if (response.statusCode == 204) {
      outputResponse.result = true;
      outputResponse.message = 'Successfully Delete!';
    } else if (response.statusCode == 404) {
      outputResponse.result = false;
      outputResponse.message = 'Item not found!';
    } else {
      outputResponse.result = false;
      outputResponse.message = 'Unable to Delete The Item!';
    }

    return outputResponse;
  }

  Future<RandomItemResponse> getRandomItemsResponse(
      {ItemType itemType = ItemType.WALLPAPER, pageNumber = 1}) async {
    Uri uri = Uri.parse(AppConfig.ITEM_RANDOM_COLLECTION_URL)
        .replace(queryParameters: {
      "page": "$pageNumber",
      "itemsPerPage": "10",
      // "enabled": "true",
      "type": itemType.name
    });
    var outputResponse = RandomItemResponse();
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
        outputResponse.result = true;
        outputResponse.itemList = deezeItemModelFromJson(response.body);
      } else {
        outputResponse.result = false;
        outputResponse.message = 'Unable to Load Data!';
      }
    } catch (ex, stack) {
      Completer().completeError(ex, stack);
      outputResponse.result = false;
      outputResponse.message = 'Unable to Load Data!';
    }

    return outputResponse;
  }

  Future<RandomItemResponse> getCurrentUserItemsResponse({
    ItemType itemType = ItemType.WALLPAPER,
    pageNumber = 1,
  }) async {
    Uri uri =
        Uri.parse("${AppConfig.BASE_URL}/items").replace(queryParameters: {
      "page": "$pageNumber",
      "itemsPerPage": "10",
      "user_id": "${user_id.$}",
      "type": itemType.name
    });
    var outputResponse = RandomItemResponse();
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-api-token': api_token.$,
        },
      );
      print('>> x-api-token : ${api_token.$}');
      print('>> response.statusCode : ${response.statusCode}');

      if (response.statusCode == 200) {
        print(response.body);
        outputResponse.result = true;
        outputResponse.itemList = deezeItemModelFromJson(response.body);
      } else if (response.statusCode == 401) {
        outputResponse.result = false;
        outputResponse.message = 'Session Expired!';
      } else {
        outputResponse.result = false;
        outputResponse.message = 'Unable to Load Data!';
      }
    } catch (ex, stack) {
      Completer().completeError(ex, stack);
      outputResponse.result = false;
      outputResponse.message = 'Unable to Load Data!';
    }

    return outputResponse;
  }
}
