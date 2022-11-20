// // To parse this JSON data, do
// //
// //     final deeze = deezeFromJson(jsonString);
//
// import 'dart:convert';
//
// Deeze deezeFromJson(String str) => Deeze.fromJson(json.decode(str));
//
// class Deeze {
//   Deeze({
//     this.context,
//     this.id,
//     this.type,
//     this.hydraMember,
//     this.hydraTotalItems,
//     this.hydraView,
//     this.hydraSearch,
//   });
//
//   String? context;
//   String? id;
//   String? type;
//   List<HydraMember>? hydraMember;
//   int? hydraTotalItems;
//   HydraView? hydraView;
//   HydraSearch? hydraSearch;
//
//   factory Deeze.fromJson(Map<String, dynamic> json) => Deeze(
//         context: json["@context"],
//         id: json["@id"],
//         type: json["@type"],
//         hydraMember: List<HydraMember>.from(
//             json["hydra:member"].map((x) => HydraMember.fromJson(x))),
//         hydraTotalItems: json["hydra:totalItems"],
//         hydraView: HydraView.fromJson(json["hydra:view"]),
//         hydraSearch: HydraSearch.fromJson(json["hydra:search"]),
//       );
// }
//
// class HydraMember {
//   HydraMember({
//     this.id,
//     this.name,
//     this.type,
//     this.file,
//     this.user,
//     this.categories,
//     this.tags,
//     this.enabled = true,
//     this.isFavourite = false,
//   });
//
//   int? id;
//   String? name;
//   String? type;
//   String? file;
//   User? user;
//   List<String>? categories;
//   List<String>? tags;
//   bool enabled;
//   bool isFavourite;
//
//   factory HydraMember.fromJson(Map<String, dynamic> json) => HydraMember(
//         id: json["id"],
//         name: json["name"],
//         type: json["type"],
//         file: json["file"],
//         user: User.fromJson(json["user"]),
//         categories: List<String>.from(json["categories"].map((x) => x)),
//         tags: List<String>.from(json["tags"].map((x) => x)),
//         enabled: json["enabled"],
//         isFavourite: json["isFavourite"] ?? false,
//       );
// }
//
// class User {
//   User({
//     this.id,
//     this.email,
//     this.firstName,
//     this.lastName,
//     this.image,
//   });
//
//   int? id;
//   String? email;
//   String? firstName;
//   String? lastName;
//   String? image;
//
//   factory User.fromJson(Map<String, dynamic> json) => User(
//         id: json["id"],
//         email: json["email"],
//         firstName: json["firstName"],
//         lastName: json["lastName"],
//         image: json["image"],
//       );
// }
//
// class HydraSearch {
//   HydraSearch({
//     this.type,
//     this.hydraTemplate,
//     this.hydraVariableRepresentation,
//     this.hydraMapping,
//   });
//
//   String? type;
//   String? hydraTemplate;
//   String? hydraVariableRepresentation;
//   List<HydraMapping>? hydraMapping;
//
//   factory HydraSearch.fromJson(Map<String, dynamic> json) => HydraSearch(
//         type: json["@type"],
//         hydraTemplate: json["hydra:template"],
//         hydraVariableRepresentation: json["hydra:variableRepresentation"],
//         hydraMapping: List<HydraMapping>.from(
//             json["hydra:mapping"].map((x) => HydraMapping.fromJson(x))),
//       );
//
//   Map<String, dynamic> toJson() => {
//         "@type": type,
//         "hydra:template": hydraTemplate,
//         "hydra:variableRepresentation": hydraVariableRepresentation,
//         "hydra:mapping":
//             List<dynamic>.from(hydraMapping!.map((x) => x.toJson())),
//       };
// }
//
// class HydraMapping {
//   HydraMapping({
//     this.type,
//     this.variable,
//     this.property,
//     this.required = false,
//   });
//
//   String? type;
//   String? variable;
//   String? property;
//   bool required;
//
//   factory HydraMapping.fromJson(Map<String, dynamic> json) => HydraMapping(
//         type: json["@type"],
//         variable: json["variable"],
//         property: json["property"],
//         required: json["required"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "@type": type,
//         "variable": variable,
//         "property": property,
//         "required": required,
//       };
// }
//
// class HydraView {
//   HydraView({
//     this.id,
//     this.type,
//     this.hydraFirst,
//     this.hydraLast,
//     this.hydraNext,
//   });
//
//   String? id;
//   String? type;
//   String? hydraFirst;
//   String? hydraLast;
//   String? hydraNext;
//
//   factory HydraView.fromJson(Map<String, dynamic> json) => HydraView(
//         id: json["@id"],
//         type: json["@type"],
//         hydraFirst: json["hydra:first"],
//         hydraLast: json["hydra:last"],
//         hydraNext: json["hydra:next"],
//       );
//
//   Map<String, dynamic> toJson() => {
//         "@id": id,
//         "@type": type,
//         "hydra:first": hydraFirst,
//         "hydra:last": hydraLast,
//         "hydra:next": hydraNext,
//       };
// }

// To parse this JSON data, do
//
//     final deezeItemModel = deezeItemModelFromJson(jsonString);

import 'dart:convert';

// List<DeezeItemModel> deezeItemModelFromJson(String str) => List<DeezeItemModel>.from(json.decode(str).map((x) => DeezeItemModel.fromJson(x)));
//
// String deezeItemModelToJson(List<DeezeItemModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class DeezeItemModel {
//   DeezeItemModel({
//     this.id,
//     this.name,
//     this.type,
//     this.file,
//     this.user,
//     this.categories,
//     this.tags,
//     this.enabled,
//     this.isFavourite = false,
//   });
//
//   int? id;
//   String? name;
//   String? type;
//   String? file;
//   User? user;
//   List<String>? categories;
//   List<String>? tags;
//   bool? enabled;
//   bool isFavourite;
//
//   factory DeezeItemModel.fromJson(Map<String, dynamic> json) => DeezeItemModel(
//     id: json["id"],
//     name: json["name"],
//     type: json["type"],
//     file: json["file"],
//     user: User.fromJson(json["user"]),
//     categories: List<String>.from(json["categories"].map((x) => x)),
//     tags: List<String>.from(json["tags"].map((x) => x)),
//     enabled: json["enabled"],
//     isFavourite: json["isFavourite"] ?? false,
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "type": type,
//     "file": file,
//     "user": user!.toJson(),
//     "categories": List<dynamic>.from(categories!.map((x) => x)),
//     "tags": List<dynamic>.from(tags!.map((x) => x)),
//     "enabled": enabled,
//   };
// }
//
// class User {
//   User({
//     this.id,
//     this.email,
//     this.firstName,
//     this.lastName,
//     this.image,
//   });
//
//   int? id;
//   String? email;
//   String? firstName;
//   String? lastName;
//   String? image;
//
//   factory User.fromJson(Map<String, dynamic> json) => User(
//     id: json["id"],
//     email: json["email"],
//     firstName: json["firstName"],
//     lastName: json["lastName"],
//     image: json["image"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "email": email,
//     "firstName": firstName,
//     "lastName": lastName,
//     "image": image,
//   };
// }

// To parse this JSON data, do
//
//     final deezeItemModel = deezeItemModelFromJson(jsonString);

import 'dart:convert';

List<DeezeItemModel> deezeItemModelFromSearchQueryJson(String str) =>
    List<DeezeItemModel>.from(json
        .decode(str)['items']
        .map((x) => DeezeItemModel.fromSearchQueryJson(x)));

List<DeezeItemModel> deezeItemModelFromJson(String str) =>
    List<DeezeItemModel>.from(
        json.decode(str).map((x) => DeezeItemModel.fromJson(x)));

String deezeItemModelToJson(List<DeezeItemModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DeezeItemModel {
  DeezeItemModel({
    this.id,
    this.name,
    this.type,
    this.file,
    this.user,
    this.isFavourite = false,
  });

  int? id;
  String? name;
  String? type;
  String? file;
  User? user;
  bool isFavourite;

  factory DeezeItemModel.fromSearchQueryJson(Map<String, dynamic> json) =>
      DeezeItemModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        file: json["file"],
        user: User(),
        isFavourite: false,
      );

  factory DeezeItemModel.fromJson(Map<String, dynamic> json) => DeezeItemModel(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        file: json["file"],
        user: User.fromJson(json["user"]),
        isFavourite: json["isFavourite"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "file": file,
        "user": user!.toJson(),
      };
}

class User {
  User({
    this.id,
    this.firstName,
    this.lastName,
    this.image,
  });

  int? id;
  String? firstName;
  String? lastName;
  String? image;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstName": firstName,
        "lastName": lastName,
        "image": image,
      };
}
