import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../models/anime.dart';
import '../models/episode.dart';
import '../models/source.dart';
import '../providers/user_preferences.dart';
import '../repositories/api_repo.dart';
import '../util/app_colors.dart';
import '../widgets/custom_player.dart';
import '../widgets/custom_tile.dart';
import '../widgets/hero_image.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Anime anime;
  final double episode;
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
  List<Source>? videoSources;
  double? currentEpisode;
  bool isLoading = true;
  bool hasError = false;

  Future<void> getEpisode({
    double episode = 1,
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
      final response = await APIRepository.getVideoSources(
          episode: widget.episodeList
              .firstWhere((element) => element.episode == currentEpisode));
      setState(() {
        videoSources = response;
        isLoading = false;
      });
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
      setState(() {
        hasError = true;
      });
    }
  }

  void scrollToEpisode({
    double episode = 1,
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
              milliseconds: min(3000, ((episode) * 60).toInt()),
            )
          : duration,
      curve: Curves.easeOut,
    );
  }

  void callback(Duration position) {
    double episode = currentEpisode ?? 1;
    Provider.of<Watchlist>(
      context,
      listen: false,
    ).addToHistory(
      episode: episode,
      anime: widget.anime,
      position: position.inSeconds,
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
                      HeroImage(
                        imageUrl: widget.anime.coverImg,
                        tag: widget.anime.id,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        fit: FlexFit.loose,
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
