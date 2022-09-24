import 'dart:convert';

TrendingSearchModel trendingSearchModelFromJson(String str) => TrendingSearchModel.fromJson(json.decode(str));

String trendingSearchModelToJson(TrendingSearchModel data) => json.encode(data.toJson());

class TrendingSearchModel {
  TrendingSearchModel({
    this.trendingTerms,
  });

  List<TrendingSearch>? trendingTerms;

  factory TrendingSearchModel.fromJson(Map<String, dynamic> json) => TrendingSearchModel(
    trendingTerms: List<TrendingSearch>.from(json["trending_terms"].map((x) => TrendingSearch.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "trending_terms": List<dynamic>.from(trendingTerms!.map((x) => x.toJson())),
  };
}

class TrendingSearch {
  TrendingSearch({
    this.trendingName,
  });

  String? trendingName;

  factory TrendingSearch.fromJson(Map<String, dynamic> json) => TrendingSearch(
    trendingName: json["term"],
  );

  Map<String, dynamic> toJson() => {
    "term": trendingName,
  };
}