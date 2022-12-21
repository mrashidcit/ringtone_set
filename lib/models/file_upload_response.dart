// To parse this JSON data, do
//
//     final signupResponse = signupResponseFromJson(jsonString);

import 'dart:convert';

import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/file_model.dart';

FileUploadResponse fileUploadResponseFromJson(String str) =>
    FileUploadResponse.fromJson(json.decode(str));

String fileUploadResponseToJson(FileUploadResponse data) =>
    json.encode(data.toJson());

class FileUploadResponse {
  FileUploadResponse({
    this.result = false,
    this.message = '',
    // this.fileModel = FileModel(fileName: const '', fileUrl: const '', fileSize: const '', fileType: const ''),
    this.fileModel,
  });

  bool result; // For Success = true, for error = false
  String message; // For Success = true, for error = false
  FileModel? fileModel;

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) =>
      FileUploadResponse(
        result: true,
        message: '',
        fileModel: FileModel(
          fileName: json['file_name'],
          fileUrl: json['file_url'],
          fileType: json['file_type'],
          fileSize: json['file_size'],
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
