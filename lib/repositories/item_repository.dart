import 'dart:convert';

import 'package:deeze_app/app_config.dart';
import 'package:deeze_app/enums/enum_item_type.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/delete_user_response.dart';
import 'package:deeze_app/models/file_upload_response.dart';
import 'package:deeze_app/models/item_create_response.dart';
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

  Future<SignInResponse> getSignInUserResponse(
    @required String email,
    @required String password,
  ) async {
    var post_body = jsonEncode({
      "email": "$email",
      "password": "$password",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/auth");
    print('>> getSignInUserResponse : url = $url');
    print('>> post_body : $post_body');
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    var signInResponse = SignInResponse(api_token: '', user: User());

    if (response.statusCode == 200) {
      signInResponse = signInResponseFromJson(response.body);
      print('>> getSignInUserResponse : response = ${response.body}');
    } else {
      signInResponse.message = jsonDecode(response.body)['error'];
    }

    return signInResponse;
  }

  Future<DeleteUserResponse> getDeleteUserAccountResponse() async {
    Uri url = Uri.parse("${AppConfig.BASE_URL}/users/${user_id.$}");
    print('>> getSignInUserResponse : url = $url');
    final response =
        await http.delete(url, headers: {'x-api-token': api_token.$});

    var deleteUserResponse =
        DeleteUserResponse(result: true, message: 'Successfully Deleted!');

    if (response.statusCode == 204) {
      deleteUserResponse.result = true;
      deleteUserResponse.message = "Successfully Deleted!";
      print('>> getSignInUserResponse : response = ${response.body}');
    }

    return deleteUserResponse;
  }
}
