import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  DatabaseHelper._();

  static Database? _db;
  Future<Database> get database async => _db ??= await _init();

  static const _dbName = 'colors.db';
  static const _dbVersion = 1;

  Future<Database> _init() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    var openDatabase2 = openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      // onUpgrade: (db, oldV, newV) async { /* ถ้าปรับ schema */ },
    );
    return await openDatabase2;
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE color_models(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        modelType TEXT NOT NULL,
        r INTEGER, g INTEGER, b INTEGER,
        c REAL, m REAL, y REAL, k REAL,
        hex TEXT,
        isFavorite INTEGER NOT NULL DEFAULT 0,
        note TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // generic helpers (Map-based ตามบท 13)
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data);
  }

  Future<List<Map<String, dynamic>>> queryAll(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> update(String table, Map<String, dynamic> data, int id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}
