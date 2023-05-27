import 'dart:convert';

import 'anime.dart';

class AnimeHistory {
  final int position;
  final int episode;
  final Anime anime;

  const AnimeHistory({
    required this.position,
    required this.episode,
    required this.anime,
  });

  factory AnimeHistory.fromJSON({required Map<String, dynamic> dataMap}) {
    return AnimeHistory(
      position: dataMap["position"],
      episode: dataMap["episode"],
      anime: Anime.fromJSON(
        dataMap: dataMap,
      ),
    );
  }
}
