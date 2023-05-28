import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/anime.dart';
import '../models/anime_history.dart';

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
          "CREATE TABLE $tableName (id TEXT PRIMARY KEY, releaseDate INTEGER, genreList TEXT, type TEXT, description TEXT, relationType TEXT, status TEXT, rating INTEGER, totalEpisodes INTEGER, cover TEXT, image TEXT, titleList TEXT, season TEXT)",
        );
        await db.execute(
          "CREATE TABLE $historyTable (id TEXT PRIMARY KEY, releaseDate INTEGER, genreList TEXT, type TEXT, description TEXT, relationType TEXT, status TEXT, rating INTEGER, totalEpisodes INTEGER, cover TEXT, image TEXT, titleList TEXT, season TEXT, position INTEGER, episode REAL)",
        );
        await db.execute(
          "CREATE TABLE $searchHistory (search_query TEXT PRIMARY KEY)",
        );
      },
      version: 1,
    );
    return sql;
  }

  static Future<List<Anime>> queryAll() async {
    final sql = await openDB();
    final data = await sql.query(tableName);
    return data.map((dataMap) => Anime.fromJSON(dataMap: dataMap)).toList();
  }

  static Future<List<AnimeHistory>> queryAllHistory() async {
    final sql = await openDB();
    final data = await sql.query(historyTable);
    return data
        .map((dataMap) => AnimeHistory.fromJSON(dataMap: dataMap))
        .toList();
  }

  static Future<List<String>> queryAllSearchHistory() async {
    final sql = await openDB();
    final data = await sql.query(searchHistory);
    return data.map((dataMap) => dataMap["search_query"].toString()).toList();
  }

  static Future<List<Anime>> query({
    required Anime anime,
  }) async {
    final sql = await openDB();
    final data = await sql.query(
      tableName,
      distinct: true,
      where: "id = ?",
      whereArgs: [anime.id],
    );
    return data.map((dataMap) => Anime.fromJSON(dataMap: dataMap)).toList();
  }

  static Future<List<AnimeHistory>> queryHistory({
    required Anime anime,
  }) async {
    final sql = await openDB();
    final data = await sql.query(
      historyTable,
      distinct: true,
      where: "id = ?",
      whereArgs: [anime.id],
    );
    return data
        .map((dataMap) => AnimeHistory.fromJSON(dataMap: dataMap))
        .toList();
  }

  static Future<int> insert({
    required Anime anime,
  }) async {
    final sql = await openDB();
    final id = await sql.insert(
      tableName,
      anime.toJSON,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  static Future<int> insertHistory({
    required Anime anime,
    required double episode,
    required int position,
  }) async {
    final sql = await openDB();
    final id = await sql.insert(
      historyTable,
      {
        "episode": episode,
        "position": position,
        ...anime.toJSON,
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
