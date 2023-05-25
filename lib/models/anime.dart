import 'package:anime_api/util/constants.dart';

class AnimeTitle {
  final String jpTitle;
  final String engTitle;

  const AnimeTitle({
    required this.jpTitle,
    required this.engTitle,
  });

  factory AnimeTitle.fromJSON({required Map<String, dynamic> dataMap}) {
    return AnimeTitle(
      jpTitle: dataMap["romaji"] ?? dataMap["romaji"] ?? "Unknown",
      engTitle: dataMap["english"] ?? dataMap["romaji"] ?? "Unknown",
    );
  }
}

class Anime {
  final AnimeTitle title;
  final String id;
  final String posterImg;
  final String coverImg;
  final String status;
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
    required this.title,
    required this.id,
    required this.posterImg,
    required this.coverImg,
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
      title: AnimeTitle.fromJSON(dataMap: dataMap["title"]),
      id: dataMap["id"],
      posterImg: dataMap["image"] ?? Constants.NOT_FOUND_IMAGE,
      coverImg: dataMap["cover"] ?? Constants.NOT_FOUND_IMAGE,
      episodes: int.parse(dataMap["totalEpisodes"] ?? "0"),
      rating: dataMap["rating"] ?? -1,
      status: dataMap["status"] ?? "Unknown",
      year: dataMap["releaseDate"] ?? -1,
      genres: dataMap["genres"] != null
          ? dataMap["genres"].map((item) => item.toString()).toList()
          : [],
      type: dataMap["type"] ?? "Unknown",
      description: dataMap["description"] ?? "",
      relationType: dataMap["relationType"] ?? "Unknown",
      relations: dataMap["relations"] != null
          ? dataMap["relations"]
              .map((dataMap) => Anime.fromJSON(dataMap: dataMap))
              .toList()
          : [],
      recommendations: dataMap["recommendations"] != null
          ? dataMap["recommendations"]
              .map((dataMap) => Anime.fromJSON(dataMap: dataMap))
              .toList()
          : [],
    );
  }
}
