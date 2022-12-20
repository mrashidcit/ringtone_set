// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

SignupResponse signupResponseFromJson(String str) =>
    SignupResponse.fromJson(json.decode(str));

String signupResponseToJson(SignupResponse data) => json.encode(data.toJson());

class SignupResponse {
  SignupResponse({
    this.result = false,
    this.message = '',
    this.apiToken = '',
    this.user,
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false
  String apiToken;
  User? user;

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
        result: true,
        apiToken: json["api_token"],
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
