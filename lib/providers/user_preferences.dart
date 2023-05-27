import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/anime.dart';
import '../models/anime_history.dart';
import '../models/enums.dart';
import '../repositories/db_repo.dart';

class Watchlist with ChangeNotifier {
  List<Anime> watchlist = [];
  List<AnimeHistory> history = [];
  String preferredQuality = "720";
  PrefferedTitle prefferedTitle = PrefferedTitle.engTitle;

  Future<void> setQuality({required String quality}) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString("preferredQuality", quality);
    preferredQuality = quality;
    notifyListeners();
    return;
  }

  Future<void> fetchQuality() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getString("preferredQuality");
    preferredQuality = data ?? "360";
    notifyListeners();
    return;
  }

  Future<void> setTitle({required PrefferedTitle title}) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setInt("prefferedTitle", title.index);
    prefferedTitle = title;
    notifyListeners();
    return;
  }

  Future<void> fetchTitle() async {
    final preferences = await SharedPreferences.getInstance();
    final data = preferences.getInt("prefferedTitle");
    if (data == null) {
      prefferedTitle = PrefferedTitle.values[0];
    } else {
      prefferedTitle = PrefferedTitle.values[data];
    }
    notifyListeners();
    return;
  }

  Future<void> fetchWatchlist() async {
    final result = await DBHelper.queryAll();
    watchlist = [...result];
    notifyListeners();
    return;
  }

  Future<void> fetchHistory() async {
    final result = await DBHelper.queryAllHistory();
    history = [...result];
    notifyListeners();
    return;
  }

  Future<List<String>> fetchSearchHistory() async {
    final result = await DBHelper.queryAllSearchHistory();
    return result;
  }

  Future<void> fetchAll() async {
    await fetchWatchlist();
    await fetchHistory();
    await fetchQuality();
    await fetchTitle();
    return;
  }

  List<Anime> get getWatchlist {
    return [...watchlist];
  }

  List<AnimeHistory> get getHistory {
    return [...history];
  }

  Future<void> addToWatchlist({
    required Anime anime,
  }) async {
    await DBHelper.insert(anime: anime);
    await fetchWatchlist();
    return;
  }

  Future<void> addToHistory({
    required Anime anime,
    required int episode,
    required int position,
  }) async {
    await DBHelper.insertHistory(
      anime: anime,
      episode: episode,
      position: position,
    );
    await fetchHistory();
    return;
  }

  Future<void> addToSearchHistory({
    required String title,
  }) async {
    await DBHelper.insertSearchHistory(title: title);
    return;
  }

  Future<void> removeFromWatchlist({
    required String id,
  }) async {
    await DBHelper.delete(itemId: id);
    await fetchWatchlist();
    return;
  }

  Future<void> toggle({
    required Anime anime,
  }) async {
    bool isPresent = watchlist.indexWhere(
          (element) => element.id == anime.id,
        ) !=
        -1;
    if (isPresent) {
      await removeFromWatchlist(id: anime.id);
      return;
    }
    await addToWatchlist(anime: anime);
    return;
  }
}
