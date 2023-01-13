// To parse this JSON data, do
//
//     final ItemCreateResponse = ItemCreateResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

ItemCreateResponse itemCreateResponseFromJson(String str) =>
    ItemCreateResponse.fromJson(json.decode(str));

// String itemCreateResponseToJson(ItemCreateResponse data) => json.encode(data.toJson());

class ItemCreateResponse {
  ItemCreateResponse({
    this.result = false,
    this.message = '',
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false

  factory ItemCreateResponse.fromJson(Map<String, dynamic> json) =>
      ItemCreateResponse(
        result: true,
        message: 'Successfully Uploaded!',
      );

  // Map<String, dynamic> toJson() => {
  //       "result": result,
  //       "user": {
  //         "id": user!.id,
  //         "firstName": user!.firstName,
  //         "lastName": user!.lastName,
  //         "image": user!.image,
  //       }
  //     };
}
