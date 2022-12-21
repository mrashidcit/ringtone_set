// To parse this JSON data, do
//
//     final DeleteUserResponse = DeleteUserResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

DeleteUserResponse deleteUserResponseFromJson(String str) =>
    DeleteUserResponse.fromJson(json.decode(str));

String DeleteUserResponseToJson(DeleteUserResponse data) =>
    json.encode(data.toJson());

class DeleteUserResponse {
  DeleteUserResponse({
    this.result = false,
    this.message = '',
  });

  bool result; // For Success = true, for error = false
  String message;

  factory DeleteUserResponse.fromJson(Map<String, dynamic> json) =>
      DeleteUserResponse(
        result: true,
        message: 'Successfully Deleted!',
      );

  Map<String, dynamic> toJson() => {
        // "result": result,
        // "id": id,
        // "items": items,
        // "firstName": first_name,
        // "lastName": last_name,
      };
}
