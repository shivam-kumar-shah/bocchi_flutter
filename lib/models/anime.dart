import 'package:anime_api/models/enums.dart';
import 'package:anime_api/util/constants.dart';

class AnimeTitle {
  final String jpTitle;
  final String engTitle;

  const AnimeTitle({
    required this.jpTitle,
    required this.engTitle,
  });

  factory AnimeTitle.fromJSON({required dynamic dataMap}) {
    String? eng;
    String? jp;
    if (dataMap.runtimeType == String) {
      jp = dataMap.toString().split('\u2022')[0];
      eng = dataMap.toString().split('\u2022')[1];
    }
    return AnimeTitle(
      jpTitle: jp ?? dataMap["romaji"] ?? dataMap["romaji"] ?? "Unknown",
      engTitle: eng ?? dataMap["english"] ?? dataMap["romaji"] ?? "Unknown",
    );
  }

  String get toJSON {
    return "$jpTitle\u2022$engTitle";
  }

  String prefTitle(PrefferedTitle prefference) {
    switch (prefference) {
      case PrefferedTitle.engTitle:
        return engTitle;
      default:
        return jpTitle;
    }
  }
}

class Anime {
  final AnimeTitle title;
  final String id;
  final String coverImg;
  final String posterImg;
  final String status;
  final String? season;
  final int year;
  final int rating;
  final int episodes;
  final List<String> genres;
  final String type;
  final String description;
  final String? relationType;
  final List<Anime> relations;
  final List<Anime> recommendations;

  const Anime({
    required this.season,
    required this.title,
    required this.id,
    required this.coverImg,
    required this.posterImg,
    required this.episodes,
    required this.rating,
    required this.status,
    required this.year,
    required this.genres,
    required this.type,
    required this.description,
    required this.relationType,
    required this.relations,
    required this.recommendations,
  });

  factory Anime.fromJSON({
    required Map<String, dynamic> dataMap,
  }) {
    return Anime(
      season: dataMap["season"],
      title: AnimeTitle.fromJSON(
          dataMap: dataMap["title"] ?? dataMap["titleList"]),
      id: dataMap["id"].toString(),
      coverImg:
          dataMap["image"] ?? dataMap["cover"] ?? Constants.NOT_FOUND_IMAGE,
      posterImg:
          dataMap["cover"] ?? dataMap["image"] ?? Constants.NOT_FOUND_IMAGE,
      episodes: dataMap["totalEpisodes"] ??
          dataMap["episodeNumber"] ??
          dataMap["episodes"] ??
          0,
      rating: dataMap["rating"] ?? -1,
      status: dataMap["status"] ?? "Unknown",
      year: dataMap["releaseDate"] ?? -1,
      genres: dataMap["genres"] != null
          ? (dataMap["genres"] as List<dynamic>)
              .map((item) => item.toString())
              .toList()
          : dataMap["genreList"] != null
              ? dataMap["genreList"].toString().split('\u2022')
              : [],
      type: dataMap["type"] ?? "Unknown",
      description: dataMap["description"] ?? "",
      relationType: dataMap["relationType"] ?? "Unknown",
      relations: dataMap["relations"] != null
          ? (dataMap["relations"] as List<dynamic>)
              .map((dataMap) => Anime.fromJSON(dataMap: dataMap))
              .toList()
          : [],
      recommendations: dataMap["recommendations"] != null
          ? (dataMap["recommendations"] as List<dynamic>)
              .map((dataMap) => Anime.fromJSON(dataMap: dataMap))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> get toJSON {
    final jsonValue = {
      "id": id,
      "releaseDate": year,
      "genreList": genres.join('\u2022'),
      "type": type,
      "description": description,
      "relationType": relationType,
      "status": status,
      "rating": rating,
      "totalEpisodes": episodes,
      "cover": coverImg,
      "image": coverImg,
      "titleList": title.toJSON,
      "season": season,
    };
    return jsonValue;
  }
}
