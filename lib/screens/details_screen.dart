import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../helpers/custom_route.dart';
import '../models/anime.dart';
import '../models/episode.dart';
import '../providers/user_preferences.dart';
import '../repositories/api_repo.dart';
import '../screens/video_player_screen.dart';
import '../util/app_colors.dart';
import '../widgets/custom_tile.dart';
import '../widgets/hero_image.dart';
import '../widgets/info_pane.dart';
import '../widgets/row_item.dart';
import '../widgets/row_label.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    super.key,
    required this.anime,
    required this.hash,
  });
  final Anime anime;
  final String hash;
  static const routeName = "/details";

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with TickerProviderStateMixin {
  Anime? fetchedAnime;
  List<Episode>? episodeList;

  bool hasError = false;
  bool isLoading = false;
  bool isDescending = false;
  String? errorMessage;

  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInCubic,
  );

  void fetchEpisodeList() async {
    if (fetchedAnime == null) return;
    setState(() {
      isLoading = true;
    });
    final anime = fetchedAnime!;
    final episodes = await APIRepository.getAllEpisodes(
      title: anime.title,
      releasedYear: anime.year,
      season: anime.season,
    );
    try {
      setState(() {
        episodeList = episodes;
      });
    } catch (err) {
      setState(() {
        hasError = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void fetchData() async {
    final result = await APIRepository.getInfo(
      malID: widget.anime.id,
    );
    try {
      setState(() {
        hasError = false;
      });
      setState(() {
        fetchedAnime = result;
      });
      fetchEpisodeList();
    } catch (err) {
      setState(() {
        hasError = true;
        errorMessage = err.toString();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    fetchData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final anime = widget.anime;
    final history = Provider.of<Watchlist>(context).getHistory;
    final historyIndex = history.indexWhere(
      (element) => element.anime.id == anime.id,
    );
    bool isPresent = historyIndex != -1;
    bool isWishlisted = Provider.of<Watchlist>(context)
            .getWatchlist
            .indexWhere((element) => element.id == anime.id) !=
        -1;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Provider.of<Watchlist>(
            context,
            listen: false,
          ).toggle(anime: anime);
        },
        tooltip: "Add to watchlist",
        child: isWishlisted
            ? const Icon(
                Icons.done_rounded,
              )
            : const Icon(
                Icons.history_outlined,
              ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  Positioned.fill(
                    child: HeroImage(
                      imageUrl: anime.coverImg,
                      tag: widget.hash,
                    ),
                  ),
                  Positioned.fill(
                    child: FadeTransition(
                      opacity: _animation,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.3),
                              Theme.of(context).scaffoldBackgroundColor
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (fetchedAnime != null)
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InfoPane(
                          anime: fetchedAnime!,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          hasError
              ? SliverToBoxAdapter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          errorMessage ?? "Some unknown error occured.",
                          style: Theme.of(context).textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightblack,
                          foregroundColor: AppColors.green,
                          minimumSize: const Size(150, 45),
                        ),
                        onPressed: fetchData,
                        child: const Text("Refresh"),
                      ),
                    ],
                  ),
                )
              : SliverToBoxAdapter(
                  child: Flex(
                    direction: Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      if (fetchedAnime == null)
                        Center(
                          child: SpinKitFoldingCube(
                            color: Theme.of(context).colorScheme.primary,
                            size: 50,
                          ),
                        ),
                      if (episodeList != null) ...[
                        ElevatedButton(
                          onPressed: episodeList!.isEmpty
                              ? null
                              : () {
                                  final data = episodeList![0];
                                  Navigator.of(context).push(
                                    CustomRoute(
                                      builder: (context) {
                                        return VideoPlayerScreen(
                                          anime: fetchedAnime!,
                                          episodeList: episodeList!,
                                          episode: isPresent
                                              ? history[historyIndex].episode
                                              : data.episode,
                                          position: isPresent
                                              ? history[historyIndex].position
                                              : 0,
                                        );
                                      },
                                    ),
                                  );
                                },
                          child: Text(
                            isPresent
                                ? "Continue Watching \u2022 E${history[historyIndex].episode}"
                                : "Start Watching",
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          child: RichText(
                            maxLines: 15,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: "Overview: ",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                              children: [
                                TextSpan(
                                  text: parse(fetchedAnime!.description)
                                      .body
                                      ?.text as String,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.grey,
                                        fontSize: 13,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Episodes",
                                style: Theme.of(context)
                                    .textTheme
                                    .displayLarge
                                    ?.copyWith(
                                      fontSize: 24,
                                    ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    isDescending = !isDescending;
                                  });
                                },
                                icon: isDescending
                                    ? const Icon(Icons.arrow_upward_rounded)
                                    : const Icon(Icons.arrow_downward_rounded),
                                label: const Text("Sort"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
          if (episodeList != null)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final data = isDescending
                      ? episodeList![episodeList!.length - 1 - index]
                      : episodeList![index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      CustomRoute(
                        builder: (context) => VideoPlayerScreen(
                          episodeList: episodeList!,
                          episode: data.episode,
                          anime: fetchedAnime!,
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: CustomTile(
                        key: ValueKey(data.id),
                        episode: data,
                      ),
                    ),
                  );
                },
                childCount: episodeList?.length ?? 0,
              ),
            ),
          if (isLoading && !hasError)
            SliverToBoxAdapter(
              child: SpinKitFadingFour(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (fetchedAnime != null) ...[
            if (fetchedAnime!.relations.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10,
                      ),
                      child: Text(
                        "Related Media",
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemExtent: 170,
                        itemBuilder: (context, index) {
                          final data = fetchedAnime!.relations[index];
                          return SizedBox(
                            child: Stack(
                              children: [
                                RowItem(
                                  anime: data,
                                ),
                                RowLabel(title: data.relationType ?? ""),
                              ],
                            ),
                          );
                        },
                        itemCount: fetchedAnime!.relations.length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (fetchedAnime!.recommendations.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 10,
                      ),
                      child: Text(
                        "Recommendations",
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 24,
                                ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemExtent: 170,
                        itemBuilder: (context, index) {
                          final data = fetchedAnime!.recommendations[index];
                          return SizedBox(
                            child: Stack(
                              children: [
                                RowItem(
                                  anime: data,
                                ),
                                RowLabel(title: data.type)
                              ],
                            ),
                          );
                        },
                        itemCount: fetchedAnime!.recommendations.length,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ],
      ),
    );
  }
}
