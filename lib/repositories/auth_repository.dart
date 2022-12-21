import 'dart:convert';

import 'package:deeze_app/app_config.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/delete_user_response.dart';
import 'package:deeze_app/models/signin_response.dart';
import 'package:deeze_app/models/signup_response.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthRepository {
  Future<SignupResponse> getSignUpUserResponse(
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String password,
  ) async {
    var post_body = jsonEncode({
      "firstName": "$firstName",
      "lastName": "$lastName",
      "email": "$email",
      "password": "$password",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/users");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    var signUpResposne = SignupResponse();

    if (response.statusCode == 201) {
      signUpResposne = signupResponseFromJson(response.body);
    } else if (response.statusCode == 409) {
      signUpResposne.result = false;
      signUpResposne.message = json.decode(response.body);
    }

    return signUpResposne;
  }

  Future<SignupResponse> getSignUpWithFacebookResponse(
    @required String firstName,
    @required String lastName,
    @required String email,
    @required String facebookId,
    @required String imageUrl,
  ) async {
    var post_body = jsonEncode({
      "firstName": "$firstName",
      "lastName": "$lastName",
      "email": "$email",
      "facebookId": "$facebookId",
      "imageUrl": "$imageUrl",
    });

    Uri url = Uri.parse("${AppConfig.BASE_URL}/users/signup/facebook");
    final response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
        },
        body: post_body);

    print('>> post_body : $post_body');

    var signUpResposne = SignupResponse();

    print('>> getSignUpWithFacebookResponse - response : ${response.body}');
    if (response.statusCode == 201) {
      signUpResposne = signupResponseFromJson(response.body);
    } else if (response.statusCode == 409) {
      signUpResposne.result = false;
      signUpResposne.message = json.decode(response.body);
    }

    return signUpResposne;
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
