import 'package:anime_api/models/enums.dart';
import 'package:anime_api/repositories/api_repo.dart';
import 'package:flutter/foundation.dart';

import '../models/anime.dart';

class LandingProvider with ChangeNotifier {
  List<Anime> trending = [];
  List<Anime> recent = [];
  List<Anime> popular = [];

  bool isLoading = true;

  Future<void> fetchTrending() async {
    trending = await APIRepository.getLanding(landing: GetLanding.trending);
    notifyListeners();
  }

  Future<void> fetchRecent() async {
    recent = await APIRepository.getLanding(landing: GetLanding.recent);
    notifyListeners();
  }

  Future<void> fetchPopular() async {
    popular = await APIRepository.getLanding(landing: GetLanding.popular);
    notifyListeners();
  }

  void fetchAll() async {
    await fetchTrending();
    await fetchRecent();
    await fetchPopular();
    isLoading = false;
    notifyListeners();
  }

  List<Anime> getData({required GetLanding landing}) {
    switch (landing) {
      case GetLanding.recent:
        return recent;
      case GetLanding.popular:
        return popular;
      default:
        return trending;
    }
  }

  LandingProvider() {
    fetchAll();
  }
}
