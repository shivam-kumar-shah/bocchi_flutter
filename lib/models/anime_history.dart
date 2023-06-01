import 'anime.dart';

class AnimeHistory {
  final int position;
  final double episode;
  final Anime anime;

  const AnimeHistory({
    required this.position,
    required this.episode,
    required this.anime,
  });

  factory AnimeHistory.fromJSON({required Map<String, dynamic> dataMap}) {
    return AnimeHistory(
      position: dataMap["position"],
      episode: double.parse(dataMap["episode"].toString()),
      anime: Anime.fromJSON(
        dataMap: dataMap,
      ),
    );
  }
}
