// To parse this JSON data, do
//
//     final signInResponse = signInResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

SignInResponse signInResponseFromJson(String str) =>
    SignInResponse.fromJson(json.decode(str));

String signInResponseToJson(SignInResponse data) => json.encode(data.toJson());

class SignInResponse {
  SignInResponse({
    this.result = false,
    this.message = '',
    required this.api_token,
    required this.user,
  });

  bool result; // For Success = true, for error = false
  String message;
  String api_token;
  User user;

  factory SignInResponse.fromJson(Map<String, dynamic> json) => SignInResponse(
        result: true,
        api_token: json["api_token"],
        user: User(
          id: json['user']["id"],
          firstName: json['user']["firstName"],
          lastName: json['user']["lastName"],
          image: json['user']["image"],
        ),
      );

  Map<String, dynamic> toJson() => {
        // "result": result,
        // "id": id,
        // "items": items,
        // "firstName": first_name,
        // "lastName": last_name,
      };
}
