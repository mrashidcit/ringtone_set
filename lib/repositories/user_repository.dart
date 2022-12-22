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

class UserRepository {
  Future<FileUploadResponse> uploadFileResponse(
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
    } else if (response.statusCode == 409) {
      // signUpResposne.result = false;
      // signUpResposne.message = json.decode(response.body);
    }

    return fileUploadResponse;
  }

  Future<UserProfileUpdateResponse> updateUserProfileImageResponse(
    @required
        String fileName, // Put that filename which is saved on webserver db
  ) async {
    var post_body = jsonEncode({
      "image": "$fileName",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/users/${user_id.$}");
    final response = await http.post(url,
        headers: {
          'Accept': 'application/json',
          "Content-Type": "application/json",
          'x-api-token': api_token.$
        },
        body: post_body);

    print('>> post_body : $post_body');

    var userProfileUpdateResponse = UserProfileUpdateResponse();

    print('>> getSignUpWithFacebookResponse - response : ${response.body}');
    if (response.statusCode == 200) {
      userProfileUpdateResponse =
          userProfileUpdateResponseFromJson(response.body);
    } else {
      userProfileUpdateResponse.result = false;
      userProfileUpdateResponse.message = 'Error while updating.';
    }

    return userProfileUpdateResponse;
  }

  Future<SignupResponse> getSignUpWithGoogleResponse(
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String googleId,
    @required String imageUrl,
  ) async {
    var post_body = jsonEncode({
      "firstName": "$firstName",
      "lastName": "$lastName",
      "email": "$email",
      "googleId": "$googleId",
      "imageUrl": "$imageUrl",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/users/signup/google");
    print('>> getSignUpWithGoogleResponse - url : $url');
    print('>> getSignUpWithGoogleResponse - post_body : $post_body');
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    var signUpResposne = SignupResponse();

    print('>> getSignUpWithGoogleResponse - response : ${response.body}');
    if (response.statusCode == 201) {
      signUpResposne = signupResponseFromJson(response.body);
    } else if (response.statusCode == 409) {
      signUpResposne.result = false;
      signUpResposne.message = json.decode(response.body);
    }

    return signUpResposne;
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
