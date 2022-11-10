import 'package:path/path.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';

import '../models/favorite.dart';

class FavoriteDataBase {
  static final FavoriteDataBase instance = FavoriteDataBase._init();

  static Database? _database;

  FavoriteDataBase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('favorite.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const id = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE $tableFavorites ( 
  ${FavoriteFields.id} $id, 
  ${FavoriteFields.currentDeviceId} $textType,
  
  ${FavoriteFields.path} $textType,
 ${FavoriteFields.deezeId} $textType,
  ${FavoriteFields.name} $textType,
    ${FavoriteFields.type} $textType
  )
''');
  }

  Future<Favorite> addFavorite(
    Favorite favorite,
  ) async {
    final db = await instance.database;

    // final json = Post.toJson();
    // final columns =
    //     '${FavoriteFields.title}, ${FavoriteFields.description}, ${FavoriteFields.time}';
    // final values =
    //     '${json[FavoriteFields.title]}, ${json[FavoriteFields.description]}, ${json[FavoriteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    final id = await db.insert(tableFavorites, favorite.toJson());
    /* for (int i = 0; i <= images.length; i++) {
      addImage(id, images[i]);
    }*/
    return favorite.copy(id: id);
  }

  Future<List<Favorite>> readAllFavoriteOfCurrentUser(
      String postOwnerId) async {
    final db = await instance.database;

    final maps = await db.query(
      tableFavorites,
      columns: FavoriteFields.values,
      where: '${FavoriteFields.currentDeviceId} = ?',
      whereArgs: [postOwnerId],
    );

    return maps.map((json) => Favorite.fromJson(json)).toList();
  }

  Future<List<Favorite>> readAllFavoriteOfCurrentMusic(String id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableFavorites,
      columns: FavoriteFields.values,
      where: '${FavoriteFields.deezeId} = ?',
      whereArgs: [id],
    );

    return maps.map((json) => Favorite.fromJson(json)).toList();
  }

  Future<int> delete(String id) async {
    final db = await instance.database;

    return await db.delete(
      tableFavorites,
      where: '${FavoriteFields.deezeId} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
