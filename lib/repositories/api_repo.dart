import 'dart:convert' show json;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' show get;

import '../models/anime.dart';
import '../models/enums.dart';
import '../models/episode.dart';
import '../models/source.dart';
import '../util/constants.dart';
import "animepahe_scrapper.dart";

class APIRepository {
  static Future<List<Anime>> searchAPI({
    required String title,
  }) async {
    try {
      final url = Uri.https(Constants.API_URL, "search/$title");
      final response = await get(url);
      final List<dynamic> data = json.decode(response.body)["results"];
      return data.map((dataMap) => Anime.fromJSON(dataMap: dataMap)).toList();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      rethrow;
    }
  }

  static Future<Anime> getInfo({required String malID}) async {
    try {
      final url = Uri.https(Constants.API_URL, "info/$malID");
      final response = await get(url);
      final Map<String, dynamic> dataMap = json.decode(response.body);
      return Anime.fromJSON(dataMap: dataMap);
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      rethrow;
    }
  }

  static Future<List<Source>> getVideoSources({
    required Episode episode,
  }) async {
    try {
      return AnimeScrapper.fetchAnimepaheEpisodesSources(
        animeID: episode.animeID.toString(),
        episodeID: episode.id.toString(),
      );
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      rethrow;
    }
  }

  static Future<List<Episode>> getEpisodeList({
    required AnimeTitle title,
    required int releasedYear,
    String? season,
    required int page,
  }) async {
    try {
      final animeId = await AnimeScrapper.getAnimepaheId(
        query: title.jpTitle,
        releasedYear: releasedYear.toString(),
        season: season ?? "unknown",
      );

      return AnimeScrapper.fetchAnimepaheEpisodes(
        animeId: animeId,
        page: page,
      );
    } catch (err) {
      rethrow;
    }
  }

  static Future<List<Episode>> getAllEpisodes({
    required AnimeTitle title,
    required int releasedYear,
    String? season,
  }) async {
    int currentPage = 1;
    List<Episode> episodeList = [];
    var tempList = await APIRepository.getEpisodeList(
      title: title,
      releasedYear: releasedYear,
      page: currentPage,
    );
    episodeList.addAll(tempList);
    while (tempList.isNotEmpty) {
      currentPage++;
      tempList = await APIRepository.getEpisodeList(
        title: title,
        releasedYear: releasedYear,
        page: currentPage,
      );
      episodeList.addAll(tempList);
    }
    return episodeList;
  }

  static Future<List<Anime>> getLanding({required GetLanding landing}) async {
    try {
      final url = Uri.https(Constants.API_URL, landing.name);
      final response = await get(url);
      final List<dynamic> data = json.decode(response.body)["results"];
      return data.map((dataMap) => Anime.fromJSON(dataMap: dataMap)).toList();
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      rethrow;
    }
  }
}
