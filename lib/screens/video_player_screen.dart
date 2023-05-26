import 'dart:math';

import 'package:anime_api/models/anime.dart';
import 'package:anime_api/repos/api_repo.dart';
import 'package:anime_api/util/app_colors.dart';
import 'package:anime_api/providers/user_preferences.dart';
import 'package:anime_api/screens/details_screen.dart';
import 'package:anime_api/widgets/custom_player.dart';
import 'package:anime_api/widgets/custom_tile.dart';
import 'package:anime_api/widgets/hero_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/episode.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Anime anime;
  final int episode;
  final List<Episode> episodeList;
  final int position;
  const VideoPlayerScreen({
    super.key,
    required this.episode,
    required this.episodeList,
    this.position = 0,
    required this.anime,
  });
  static const routeName = "/watch";

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final ScrollController _controller = ScrollController();
  List<dynamic>? videoSources;
  int? currentEpisode;
  bool isLoading = true;
  bool hasError = false;

  Future<void> getEpisode({
    int episode = 1,
    required int position,
  }) async {
    Provider.of<Watchlist>(
      context,
      listen: false,
    ).addToHistory(
      episode: episode,
      anime: widget.anime,
      position: position,
    );
    setState(() {
      isLoading = true;
      currentEpisode = episode;
    });
    if (_controller.hasClients) {
      scrollToEpisode(
        episode: currentEpisode!,
        duration: const Duration(milliseconds: 300),
      );
    }
    try {
      final response = await APIRepo.getVideoSources(
        episodeID: widget.episodeList
            .firstWhere((element) => element.episode == currentEpisode)
            .id,
        animeID: widget.anime.id,
      );
      setState(() {
        videoSources = response;
        isLoading = false;
      });
    } catch (err) {
      setState(() {
        hasError = true;
      });
    }
  }

  void scrollToEpisode({
    int episode = 1,
    Duration duration = Duration.zero,
  }) {
    double position = 100 * ((episode - widget.episodeList[0].episode) * 1.0);
    if (episode * 60 > 3000) {
      _controller.jumpTo(min(position, _controller.position.maxScrollExtent));
    }
    _controller.animateTo(
      min(position, _controller.position.maxScrollExtent),
      duration: duration == Duration.zero
          ? Duration(
              milliseconds: min(3000, ((episode) * 60)),
            )
          : duration,
      curve: Curves.easeOut,
    );
  }

  Future<void> callback({required int? position}) async {
    int episode = currentEpisode ?? 1;
    await Provider.of<Watchlist>(
      context,
      listen: false,
    ).addToHistory(
      episode: episode,
      anime: widget.anime,
      position: position ?? 0,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      currentEpisode = widget.episode;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToEpisode(episode: currentEpisode!);
    });
    getEpisode(
      position: widget.position,
      episode: widget.episode,
    );
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    int currentLength = widget.episodeList.length;
    final prefferedTitle =
        Provider.of<Watchlist>(context, listen: false).prefferedTitle;
    if (prefferedTitle == PrefferedTitle.engTitle) {
    } else {}
    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: hasError
                      ? Center(
                          child: Text(
                            "Sorry, Anime not found🥲",
                            style: Theme.of(context).textTheme.displayLarge,
                          ),
                        )
                      : isLoading == false && videoSources != null
                          ? CustomPlayer(
                              streams: videoSources!,
                              callback: callback,
                              initialPosition: currentEpisode == widget.episode
                                  ? widget.position
                                  : 0,
                              nextEpisode: () {
                                getEpisode(
                                  episode: currentEpisode == currentLength
                                      ? currentLength + 1
                                      : currentEpisode! + 1,
                                  position: 0,
                                );
                              },
                              isLast: currentEpisode == currentLength,
                            )
                          : Container(
                              color: Theme.of(context).colorScheme.surface,
                              child: Center(
                                child: SpinKitWave(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                ),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  height: 140,
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      GestureDetector(
                        onTap: () {
                          MaterialPageRoute(
                            builder: (context) => DetailsScreen(
                              anime: widget.anime,
                            ),
                          );
                        },
                        child: HeroImage(
                          imageUrl: widget.anime.posterImg,
                          tag: widget.anime.id,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Currently Watching",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              widget.anime.title.prefTitle(prefferedTitle),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 15,
                                  ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Episode",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              currentEpisode.toString(),
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                "Up Next",
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 24,
                    ),
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Flexible(
              child: ListView.builder(
                controller: _controller,
                itemBuilder: (context, index) {
                  final episode = widget.episodeList[index];

                  return InkWell(
                    onTap: () {
                      if (episode.episode == currentEpisode) return;
                      getEpisode(
                        episode: episode.episode,
                        position: 0,
                      );
                    },
                    child: Container(
                      color: episode.episode == currentEpisode
                          ? AppColors.grey
                          : null,
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: CustomTile(
                        episode: episode,
                        key: ValueKey(episode.id),
                      ),
                    ),
                  );
                },
                itemCount: widget.episodeList.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}
