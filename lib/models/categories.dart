// // To parse this JSON data, do
// //
// //     final categories = categoriesFromJson(jsonString);
//
// import 'dart:convert';
//
// Categories categoriesFromJson(String str) =>
//     Categories.fromJson(json.decode(str));
//
// class Categories {
//   Categories({
//     this.context,
//     this.id,
//     this.type,
//     this.hydraMember,
//     this.hydraTotalItems,
//     this.hydraView,
//   });
//
//   String? context;
//   String? id;
//   String? type;
//   List<HydraMember>? hydraMember;
//   int? hydraTotalItems;
//   HydraView? hydraView;
//
//   factory Categories.fromJson(Map<String, dynamic> json) => Categories(
//         context: json["@context"],
//         id: json["@id"],
//         type: json["@type"],
//         hydraMember: List<HydraMember>.from(
//             json["hydra:member"].map((x) => HydraMember.fromJson(x))),
//         hydraTotalItems: json["hydra:totalItems"],
//         hydraView: HydraView.fromJson(json["hydra:view"]),
//       );
// }
//
// class HydraMember {
//   HydraMember({
//     this.id,
//     this.name,
//     this.items,
//     this.image,
//   });
//
//   int? id;
//   String? name;
//   List<String>? items;
//   String? image;
//
//   factory HydraMember.fromJson(Map<String, dynamic> json) => HydraMember(
//         id: json["id"],
//         name: json["name"],
//         items: List<String>.from(json["items"].map((x) => x)),
//         image: json["image"],
//       );
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
//     final categories = categoriesFromJson(jsonString);

import 'dart:convert';

List<CategoriesModel> categoriesFromJson(String str) => List<CategoriesModel>.from(json.decode(str).map((x) => CategoriesModel.fromJson(x)));

String categoriesToJson(List<CategoriesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoriesModel {
  CategoriesModel({
    this.id,
    this.name,
    this.items,
    this.image,
  });

  int? id;
  String? name;
  List<String>? items;
  String? image;

  factory CategoriesModel.fromJson(Map<String, dynamic> json) => CategoriesModel(
    id: json["id"],
    name: json["name"],
    items: List<String>.from(json["items"].map((x) => x)),
    image: json["image"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "items": List<dynamic>.from(items!.map((x) => x)),
    "image": image,
  };
}

