import 'dart:convert';

import 'package:deeze_app/app_config.dart';
import 'package:deeze_app/models/deeze_model.dart';
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

  Future<SignupResponse> getSignUpUserWithThirdPartyResponse(
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

    print('>> post_body : $post_body');

    var signUpResposne = SignupResponse();

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
}
