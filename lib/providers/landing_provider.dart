import 'package:anime_api/models/enums.dart';
import 'package:anime_api/repositories/api_repo.dart';
import 'package:flutter/foundation.dart';

import '../models/anime.dart';

class LandingProvider with ChangeNotifier {
  List<Anime> trending = [];
  List<Anime> recent = [];
  List<Anime> popular = [];

  Future<void> fetchTrending() async {
    try {
      trending = await APIRepository.getLanding(landing: GetLanding.trending);
    } catch (err) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> fetchRecent() async {
    try {
      recent = await APIRepository.getLanding(landing: GetLanding.recent);
    } catch (err) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> fetchPopular() async {
    try {
      popular = await APIRepository.getLanding(landing: GetLanding.popular);
    } catch (err) {
      rethrow;
    }

    notifyListeners();
  }

  void fetchAll() async {
    await fetchTrending();
    await fetchRecent();
    await fetchPopular();
    notifyListeners();
  }

  List<Anime> getData({required GetLanding landing}) {
    try {
      switch (landing) {
        case GetLanding.recent:
          if (recent.isEmpty) {
            fetchRecent();
          }
          return recent;
        case GetLanding.popular:
          if (popular.isEmpty) {
            fetchPopular();
          }
          return popular;
        default:
          if (trending.isEmpty) {
            fetchTrending();
          }
          return trending;
      }
    } catch (err) {
      rethrow;
    }
  }

  LandingProvider() {
    fetchAll();
  }
}
