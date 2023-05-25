import 'dart:convert';

import 'package:http/http.dart';
import 'package:html/parser.dart' as html;

class AnimeScrapper {
  static const _baseUrl = "animepahe.ru";
  // static const _apiUrl = "anime-api-vnkr.onrender.com";
  static const _apiUrl = "relieved-cyan-tuxedo.cyclic.app";
  static const _headers = {
    "User-Agent":
        "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Mobile Safari/537.36",
  };

  static Future<String> getAnimepaheId({
    required String query,
    required String releasedYear,
    String season = "unknown",
  }) async {
    try {
      final url = Uri.https(_baseUrl, "api", {"m": "search", "q": query});
      final response = await get(url, headers: _headers);
      final responseBody = json.decode(response.body)["data"] as List<dynamic>;
      final searchList = responseBody.map((anime) {
        return {
          "animeTitle": anime["title"],
          "animeId": anime["session"],
          "animeImg": anime["poster"],
          "totalEpisodes": anime["episodes"],
          "type": anime["type"],
          "status": anime["status"],
          "season": anime["season"].toString().toLowerCase().trim(),
          "year": anime["year"].toString(),
          "score": anime["score"],
        };
      }).toList();
      if (searchList.isEmpty) return "";
      final foundAnime = searchList.firstWhere(
        (element) {
          if (season == "unknown") {
            return element["year"].toString() == releasedYear;
          }
          return element["year"].toString() == releasedYear &&
              element["season"].toString() == season;
        },
        orElse: () => searchList[0],
      );
      if (foundAnime["error"] != null) {
        return "";
      }
      return foundAnime["animeId"];
    } catch (err) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchAnimepaheEpisodes({
    required String animeId,
    required int page,
  }) async {
    if (animeId == "") {
      return {
        "error": "No anime found",
      };
    }

    final url = Uri.https(_baseUrl, "/api", {
      "m": "release",
      "id": animeId.toString(),
      "sort": "episode_asc",
      "page": page.toString(),
    });
    final response = await get(url);
    return json.decode(response.body);
    // final responseBody = json.decode(response.body)["data"] as List<dynamic>;
    // final episodeList = responseBody.map((ep) {
    //   return {
    //     "epNum": ep["episode"],
    //     "episodeId": ep["session"],
    //     "thumbnail": ep["snapshot"],
    //     "duration": ep["duration"],
    //     "isBD": ep["disc"] == "BD" ? true : false,
    //   };
    // }).toList();

    // return episodeList;
  }

  static Future<List<Map<String, String>>> fetchAnimepaheEpisodesSources({
    required String animeId,
    required String episodeId,
  }) async {
    final url = Uri.https(_baseUrl, "/play/$animeId/$episodeId");
    try {
      final response = await get(url);
      final parsedResponse = html.parse(response.body);
      final sourceList = parsedResponse
          .getElementById(
            "resolutionMenu",
          )
          ?.children
          .map((elem) {
        final attributes = elem.attributes;
        return {
          "referrer": attributes["data-src"].toString(),
          "resolution": attributes["data-resolution"].toString(),
          "audio": attributes["data-audio"].toString(),
          "group": attributes["data-fansub"].toString(),
        };
      }).toList();
      final streamInfoList =
          parsedResponse.getElementById("pickDownload")?.children;
      final referrerList = sourceList
          ?.map(
            (e) => {
              "url": e["referrer"],
              "audio": e["audio"],
              "resolution": e["resolution"],
            },
          )
          .toList();
      final apiCall = Uri.https(_apiUrl, "/watch", {
        "url": json.encode(referrerList),
      });
      final kwikUrl = json.decode((await get(apiCall)).body) as List<dynamic>;
      int size = sourceList?.length as int;
      for (int i = 0; i < size; i++) {
        sourceList![i] = {
          ...sourceList[i],
          "url": kwikUrl.firstWhere((element) =>
              element["audio"] == sourceList[i]["audio"] &&
              element["resolution"] == sourceList[i]["resolution"])["url"],
          "streamInfo": streamInfoList![i].firstChild?.text ?? "",
        };
      }
      return sourceList ?? [{}];
    } catch (err) {
      rethrow;
    }
  }
}
