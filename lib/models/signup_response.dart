// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

SignupResponse signupResponseFromJson(String str) =>
    SignupResponse.fromJson(json.decode(str));

String signupResponseToJson(SignupResponse data) => json.encode(data.toJson());

class SignupResponse {
  SignupResponse({
    this.result = false,
    this.message = '',
    this.id,
    this.items,
    this.first_name,
    this.last_name,
    this.image,
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false
  int? id;
  List<String>? items;
  String? first_name;
  String? last_name;
  String? image;

  factory SignupResponse.fromJson(Map<String, dynamic> json) => SignupResponse(
        result: true,
        id: json["id"],
        items: [],
        first_name: json["firstName"],
        last_name: json["lastName"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "id": id,
        "items": items,
        "firstName": first_name,
        "lastName": last_name,
      };
}
