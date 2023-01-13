// To parse this JSON data, do
//
//     final ItemDeleteResponse = ItemCreateResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';

// ItemDeleteResponse itemCreateResponseFromJson(String str) =>
//     ItemDeleteResponse.fromJson(json.decode(str));

// String itemCreateResponseToJson(ItemDeleteResponse data) => json.encode(data.toJson());

class ItemDeleteResponse {
  ItemDeleteResponse({
    this.result = false,
    this.message = '',
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false

  // factory ItemDeleteResponse.fromJson(Map<String, dynamic> json) =>
  //     ItemDeleteResponse(
  //       result: true,
  //       message: 'Successfully Uploaded!',
  //     );

}
