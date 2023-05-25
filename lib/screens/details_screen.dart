import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../helpers/custom_route.dart';
import '../helpers/http_helper.dart';
import '../screens/video_player_screen.dart';
import '../providers/user_preferences.dart';
import '../widgets/row_item.dart';
import '../widgets/custom_tile.dart';
import '../widgets/hero_image.dart';
import '../widgets/info_pane.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});
  static const routeName = "/details";

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? fetchedData;
  String? animeId;
  List<dynamic>? episodeList;
  bool hasError = false;
  String? errorMessage;
  bool loadingEpisode = false;
  bool descending = false;

  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInCubic,
  );

  void fetchEpisodeList() async {
    try {
      List<dynamic> tempList = [];
      int nextPage = 1;
      setState(() {
        loadingEpisode = true;
      });
      while (nextPage != -1) {
        final result = await HttpHelper.getEpisodeList(
          title: fetchedData!["title"]["romaji"] ?? "Unknown",
          releasedYear: fetchedData?["releaseDate"] ?? 0,
          page: nextPage,
        );
        if (animeId == null) {
          setState(() {
            animeId = result["animeId"];
          });
        }
        tempList = [...tempList, ...result["episodes"]["data"]];
        nextPage = result["episodes"]["current_page"] ==
                result["episodes"]["last_page"]
            ? -1
            : result["episodes"]["current_page"] + 1;
      }
      setState(() {
        loadingEpisode = false;
        episodeList = tempList;
      });
    } catch (err) {
      setState(() {
        hasError = true;
      });
    }
  }

  void getData() async {
    try {
      setState(() {
        hasError = false;
      });
      final result = await HttpHelper.getInfo(
        malID: (int.parse(
          (ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>)["id"],
        )),
      );
      setState(() {
        fetchedData = result;
      });
      if (episodeList == null) fetchEpisodeList();
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
    getData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<Watchlist>(context).getHistory;
    int index = -1;
    bool isPresent = false;
    if (fetchedData != null) {
      index = history.indexWhere((item) => item["id"] == fetchedData!["id"]);
      isPresent = !(Provider.of<Watchlist>(context).getWatchlist.indexWhere(
                (element) => element["id"] == fetchedData!["id"],
              ) ==
          -1);
    }
    return Scaffold(
      floatingActionButton: fetchedData != null
          ? FloatingActionButton(
              onPressed: () async {
                await Provider.of<Watchlist>(
                  context,
                  listen: false,
                ).toggle(
                  id: fetchedData!["id"],
                  title: json.encode(fetchedData!["title"]),
                  image: fetchedData!["image"],
                );
              },
              tooltip: "Add to watchlist",
              child: isPresent
                  ? const Icon(
                      Icons.done_rounded,
                    )
                  : const Icon(
                      Icons.history_outlined,
                    ),
            )
          : null,
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
                      imageUrl: (ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>)["image"],
                      tag: (ModalRoute.of(context)?.settings.arguments
                          as Map<String, dynamic>)["tag"],
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
                  if (fetchedData != null)
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: InfoPane(
                          status: fetchedData!["status"],
                          episodes: fetchedData!["totalEpisodes"].toString(),
                          season: fetchedData!["season"],
                          genres: fetchedData!["genres"],
                          releaseDate: fetchedData!["releaseDate"] ?? 0,
                          title: fetchedData!["title"] ?? "Unknown",
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
                        onPressed: getData,
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
                      if (fetchedData == null)
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
                                          animeId: animeId ?? "",
                                          title: fetchedData!["title"],
                                          episodeList: episodeList!,
                                          episode: index != -1
                                              ? history[index]["episode"]
                                              : data["episode"],
                                          image: fetchedData!["image"],
                                          id: fetchedData!["id"],
                                          position: index != -1
                                              ? history[index]["position"]
                                              : 0,
                                        );
                                      },
                                    ),
                                  );
                                },
                          child: Text(
                            index != -1
                                ? "Continue Watching \u2022 E${history[index]["episode"]}"
                                : "Start Watching",
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (fetchedData!["description"] != null)
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
                                    text: parse(fetchedData!["description"])
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
                        if (fetchedData?["totalEpisodes"] != null)
                          if (fetchedData?["totalEpisodes"] > 0)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                        descending = !descending;
                                      });
                                    },
                                    icon: descending
                                        ? Icon(Icons.arrow_upward_rounded)
                                        : Icon(Icons.arrow_downward_rounded),
                                    label: Text("Sort"),
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
                  final data = descending
                      ? episodeList![episodeList!.length - 1 - index]
                      : episodeList![index];
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      CustomRoute(
                        builder: (context) => VideoPlayerScreen(
                          title: fetchedData!["title"],
                          episodeList: episodeList!,
                          animeId: animeId ?? "",
                          episode: data["episode"],
                          image: fetchedData!["image"],
                          id: fetchedData!["id"],
                        ),
                      ),
                    ),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      child: CustomTile(
                        image: data["snapshot"],
                        episodeNumber: data["episode"].toString(),
                        airDate: data["created_at"],
                        description: data["disc"],
                        duration: data["duration"],
                        key: ValueKey(data["episode"]),
                        title: data["title"],
                      ),
                    ),
                  );
                },
                childCount: episodeList?.length ?? 0,
              ),
            ),
          if (loadingEpisode && !hasError)
            SliverToBoxAdapter(
              child: SpinKitFadingFour(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          if (fetchedData != null) ...[
            if (fetchedData!["relations"].length != 0) ...[
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
                          final data = fetchedData!["relations"][index];
                          return SizedBox(
                            child: Stack(
                              children: [
                                RowItem(
                                  title: data["title"],
                                  tag: data["id"].toString(),
                                  image: data["image"],
                                  id: data["id"].toString(),
                                  disabled: data["episodes"] == null ||
                                      data["malId"] == null,
                                ),
                                Positioned(
                                  top: 20,
                                  right: 4,
                                  child: FittedBox(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(5),
                                        ),
                                        color: Colors.red,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 3,
                                      ),
                                      child: Text(
                                        data["relationType"][0] +
                                            data["relationType"]
                                                .toString()
                                                .toLowerCase()
                                                .substring(1),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: fetchedData!["relations"].length,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (fetchedData!["recommendations"].length != 0) ...[
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
                          final data = fetchedData!["recommendations"][index];
                          return SizedBox(
                            child: Stack(
                              children: [
                                RowItem(
                                  title: data["title"],
                                  tag: data["id"].toString(),
                                  image: data["image"] ?? "",
                                  id: data["id"].toString(),
                                  disabled: (data["status"]
                                                  .toString()
                                                  .toLowerCase() ==
                                              "not yet aired" ||
                                          data["malId"] == null) ||
                                      data["episodes"] == null,
                                ),
                                Positioned(
                                  top: 20,
                                  right: 4,
                                  child: FittedBox(
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.horizontal(
                                          left: Radius.circular(5),
                                        ),
                                        color: Colors.red,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 3,
                                      ),
                                      child: Text(
                                        data["type"],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        itemCount: fetchedData!["recommendations"].length,
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
