// To parse this JSON data, do
//
//     final tags = tagsFromJson(jsonString);

import 'dart:convert';

Tags tagsFromJson(String str) => Tags.fromJson(json.decode(str));

String tagsToJson(Tags data) => json.encode(data.toJson());

class Tags {
  Tags({
    this.context,
    this.id,
    this.type,
    this.hydraMember,
    this.hydraTotalItems,
    this.hydraView,
  });

  String? context;
  String? id;
  String? type;
  List<HydraMember>? hydraMember;
  int? hydraTotalItems;
  HydraView? hydraView;

  factory Tags.fromJson(Map<String, dynamic> json) => Tags(
        context: json["@context"],
        id: json["@id"],
        type: json["@type"],
        hydraMember: List<HydraMember>.from(
            json["hydra:member"].map((x) => HydraMember.fromJson(x))),
        hydraTotalItems: json["hydra:totalItems"],
        hydraView: HydraView.fromJson(json["hydra:view"]),
      );

  Map<String, dynamic> toJson() => {
        "@context": context,
        "@id": id,
        "@type": type,
        "hydra:member": List<dynamic>.from(hydraMember!.map((x) => x.toJson())),
        "hydra:totalItems": hydraTotalItems,
        "hydra:view": hydraView!.toJson(),
      };
}

class HydraMember {
  HydraMember({
    this.id,
    this.type,
    this.hydraMemberId,
    this.name,
    this.items,
  });

  String? id;
  Type? type;
  int? hydraMemberId;
  String? name;
  List<String>? items;

  factory HydraMember.fromJson(Map<String, dynamic> json) => HydraMember(
        id: json["@id"],
        type: typeValues.map![json["@type"]],
        hydraMemberId: json["id"],
        name: json["name"],
        items: List<String>.from(json["items"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "@id": id,
        "@type": typeValues.reverse[type],
        "id": hydraMemberId,
        "name": name,
        "items": List<dynamic>.from(items!.map((x) => x)),
      };
}

enum Type { TAG }

final typeValues = EnumValues({"Tag": Type.TAG});

class HydraView {
  HydraView({
    this.id,
    this.type,
    this.hydraFirst,
    this.hydraLast,
    this.hydraNext,
  });

  String? id;
  String? type;
  String? hydraFirst;
  String? hydraLast;
  String? hydraNext;

  factory HydraView.fromJson(Map<String, dynamic> json) => HydraView(
        id: json["@id"],
        type: json["@type"],
        hydraFirst: json["hydra:first"],
        hydraLast: json["hydra:last"],
        hydraNext: json["hydra:next"],
      );

  Map<String, dynamic> toJson() => {
        "@id": id,
        "@type": type,
        "hydra:first": hydraFirst,
        "hydra:last": hydraLast,
        "hydra:next": hydraNext,
      };
}

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map!.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap!;
  }
}
