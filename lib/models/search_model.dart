// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);

import 'dart:convert';

List<SearchModel> searchModelFromJson(String str) {
  print('>> searchModelFromJson - str = $str');

  // try {
  // print('>> items = ' + JsonDecoder(json.decode(str))['items'] );
  // print('>> items = ' + jsonDecode(str)['found']['total'].toString());
  // print('>> items = ' + json.decode(str)['found']['total'].toString());
  // json.decode(str).map((x) {
  //   print(' $x');
  // });

  // return List<SearchModel>.from(json.decode(str)['items'].map((x) => SearchModel.fromJson(x)));
  return List<SearchModel>.from(json.decode(str)['items'].map((x) {
    print(">> id , name : ${x['id']}  ${x['name']}");
    print(">> type = ${x.runtimeType}");
    print('>> $x');
    return SearchModel.fromJson(x as Map<String, dynamic>);
  }));
  // } catch (ex) {
  //   print('>> Exception : ' + ex.toString());
  //   return [];
  // }
}

String searchModelToJson(List<SearchModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SearchModel {
  SearchModel({
    this.id,
    this.name,
    this.type,
    this.file,
    this.user,
    this.categories,
    this.tags,
    this.enabled,
  });

  int? id;
  String? name;
  String? type;
  String? file;
  User? user;
  List<String>? categories;
  List<String>? tags;
  bool? enabled;

  factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        file: json["file"],
        user: (json["user"] != null) ? User.fromJson(json["user"]) : User(),
        categories: (json["categories"] != null)
            ? List<String>.from(json["categories"].map((x) => x))
            : [],
        tags: (json["tags"] != null)
            ? List<String>.from(json["tags"].map((x) => x))
            : [],
        enabled: json["enabled"] ?? null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "file": file,
        "user": user!.toJson(),
        "categories": List<dynamic>.from(categories!.map((x) => x)),
        "tags": List<dynamic>.from(tags!.map((x) => x)),
        "enabled": enabled,
      };
}

class User {
  User({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.image,
  });

  int? id;
  String? email;
  String? firstName;
  String? lastName;
  String? image;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        email: json["email"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "image": image,
      };
}
