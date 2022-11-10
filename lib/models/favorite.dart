const String tableFavorites = 'Favorites';

class FavoriteFields {
  static final List<String> values = [
    /// Add all fields
    currentDeviceId, path, deezeId, name, type
  ];

  static const String id = '_id';
  static const String currentDeviceId = 'currentDeviceId';
  static const String path = "path";
  static const String name = "name";
  static const String deezeId = "deezeId";
  static const String type = "type";
}

class Favorite {
  final int? id;
  final String path;
  final String deezeId;
  final String currentDeviceId;
  final String name;
  final String type;
  const Favorite(
      {this.id,
      required this.currentDeviceId,
      required this.path,
      required this.type,
      required this.name,
      required this.deezeId});

  Favorite copy({
    int? id,
    String? currentDeviceId,
    String? path,
    String? deezeId,
    String? name,
    String? type,
  }) =>
      Favorite(
        currentDeviceId: currentDeviceId ?? this.currentDeviceId,
        id: id ?? this.id,
        deezeId: deezeId ?? this.deezeId,
        path: path ?? this.path,
        name: name ?? this.name,
        type: type ?? this.type,
      );

  static Favorite fromJson(Map<String, Object?> json) => Favorite(
        id: json[FavoriteFields.id] as int?,
        currentDeviceId: json[FavoriteFields.currentDeviceId] as String,
        path: json[FavoriteFields.path] as String,
        deezeId: json[FavoriteFields.deezeId] as String,
        name: json[FavoriteFields.name] as String,
        type: json[FavoriteFields.type] as String,
      );

  Map<String, Object?> toJson() => {
        FavoriteFields.currentDeviceId: currentDeviceId,
        FavoriteFields.id: id,
        FavoriteFields.path: path,
        FavoriteFields.deezeId: deezeId,
        FavoriteFields.name: name,
        FavoriteFields.type: type,
      };
}
