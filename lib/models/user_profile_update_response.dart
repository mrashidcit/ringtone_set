// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

UserProfileUpdateResponse userProfileUpdateResponseFromJson(String str) =>
    UserProfileUpdateResponse.fromJson(json.decode(str));

String userProfileUpdateResponseToJson(UserProfileUpdateResponse data) =>
    json.encode(data.toJson());

class UserProfileUpdateResponse {
  UserProfileUpdateResponse({
    this.result = false,
    this.message = '',
    this.user,
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false
  User? user;

  factory UserProfileUpdateResponse.fromJson(Map<String, dynamic> json) =>
      UserProfileUpdateResponse(
        result: true,
        message: '',
        user: User(
          id: json["id"],
          firstName: json["firstName"],
          lastName: json["lastName"],
          image: json["image"],
        ),
      );

  Map<String, dynamic> toJson() => {
        // "result": result,
        // "user": {
        //   "id": user!.id,
        //   "firstName": user!.firstName,
        //   "lastName": user!.lastName,
        //   "image": user!.image,
        // }
      };
}
