// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

SignupWithThirdPartyResponse signupWithThirdPartyResponseFromJson(String str) =>
    SignupWithThirdPartyResponse.fromJson(json.decode(str));

String signupThirdPartyResponseToJson(SignupWithThirdPartyResponse data) =>
    json.encode(data.toJson());

class SignupWithThirdPartyResponse {
  SignupWithThirdPartyResponse({
    this.result = false,
    this.message = '',
    this.apiToken = '',
    this.user,
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false
  String apiToken;
  User? user;

  factory SignupWithThirdPartyResponse.fromJson(Map<String, dynamic> json) =>
      SignupWithThirdPartyResponse(
        result: true,
        apiToken: json["api_token"] ?? '',
        user: User(
          id: json['user']["id"],
          firstName: json['user']["firstName"],
          lastName: json['user']["lastName"],
          image: json['user']["image"],
        ),
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "user": {
          "id": user!.id,
          "firstName": user!.firstName,
          "lastName": user!.lastName,
          "image": user!.image,
        }
      };
}
