import 'dart:convert';

import 'package:deeze_app/app_config.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/delete_user_response.dart';
import 'package:deeze_app/models/file_upload_response.dart';
import 'package:deeze_app/models/signin_response.dart';
import 'package:deeze_app/models/signup_response.dart';
import 'package:deeze_app/models/user_profile_update_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class FileRepository {
  Future<FileUploadResponse> getUploadFileResponse(
    @required XFile file,
  ) async {
    var post_body = jsonEncode({});

    Uri url = Uri.parse("${AppConfig.BASE_URL}/upload");
    print('>> uploadFileResponse - ${file.name.split('.')[1]}');
    print('>> x-api-token: ${api_token.$}');
    var request = await http.MultipartRequest('POST', url)
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
        'x-api-token': api_token.$,
      })
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: new MediaType('image', file.name.split('.')[1]),
        // contentType: new MediaType('image', 'jpeg'),
      ));

    var response = await request.send();

    var fileUploadResponse = FileUploadResponse();

    print(
        '>> uploadFileResponse - response.statusCode : ${response.statusCode}');

    // print('>> uploadFileResponse - response.toString : ${response.toString()}');
    // print(
    //     '>> uploadFileResponse - response.body : ${await response.stream.bytesToString()}');

    if (response.statusCode == 200) {
      fileUploadResponse =
          fileUploadResponseFromJson(await response.stream.bytesToString());

      // signUpResposne = signupResponseFromJson(response.body);
    } else if (response.statusCode == 401) {
      fileUploadResponse.result = false;
      fileUploadResponse.message = "Session Expired!";
      // signUpResposne.message = json.decode(response.body);
    }

    return fileUploadResponse;
  }
}
