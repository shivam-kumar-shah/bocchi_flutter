import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const tableName = "watchlist";
  static const historyTable = "history";
  static const searchHistory = "search_history";

  static Future<Database> openDB() async {
    final path = join(await getDatabasesPath(), "user.db");
    final sql = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE $tableName (id TEXT PRIMARY KEY, title TEXT, image TEXT)",
        );
        await db.execute(
          "CREATE TABLE $historyTable (id TEXT PRIMARY KEY, title TEXT, image TEXT, episode INTEGER, position INTEGER)",
        );
        await db.execute(
            "CREATE TABLE $searchHistory (search_query TEXT PRIMARY KEY)");
      },
      version: 1,
    );
    return sql;
  }

  static Future<List<Map<String, dynamic>>> queryAll() async {
    final sql = await openDB();
    final data = await sql.query(tableName);
    return data;
  }

  static Future<List<Map<String, dynamic>>> queryAllHistory() async {
    final sql = await openDB();
    final data = await sql.query(historyTable);
    return data;
  }

  static Future<List<Map<String, dynamic>>> queryAllSearchHistory() async {
    final sql = await openDB();
    final data = await sql.query(searchHistory);
    return data;
  }

  static Future<List<Map<String, dynamic>>> query({
    required String id,
  }) async {
    final sql = await openDB();
    final data = await sql.query(
      tableName,
      distinct: true,
      where: "id = ?",
      whereArgs: [id],
    );
    return data;
  }

  static Future<List<Map<String, dynamic>>> queryHistory({
    required String id,
  }) async {
    final sql = await openDB();
    final data = await sql.query(
      historyTable,
      distinct: true,
      where: "id = ?",
      whereArgs: [id],
    );
    return data;
  }

  static Future<int> insert({
    required String itemId,
    required String title,
    required String image,
  }) async {
    final sql = await openDB();
    final id = await sql.insert(
      tableName,
      {
        "id": itemId,
        "title": title,
        "image": image,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<int> insertHistory({
    required String itemId,
    required String image,
    required int episode,
    required String title,
    required int position,
  }) async {
    final sql = await openDB();
    final id = await sql.insert(
      historyTable,
      {
        "id": itemId,
        "image": image,
        "episode": episode,
        "position": position,
        "title": title,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<void> insertSearchHistory({
    required String title,
  }) async {
    final sql = await openDB();
    await sql.insert(
      searchHistory,
      {
        "search_query": title,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return;
  }

  static dynamic delete({required String itemId}) async {
    final sql = await openDB();
    final id = await sql.delete(
      tableName,
      where: "id = ?",
      whereArgs: [itemId],
    );
    return id;
  }

  static dynamic deleteHistory({required String itemId}) async {
    final sql = await openDB();
    final id = await sql.delete(
      historyTable,
      where: "id = ?",
      whereArgs: [itemId],
    );
    return id;
  }
}
