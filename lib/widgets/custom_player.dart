import 'package:anime_api/providers/user_preferences.dart';
import 'package:anime_api/widgets/custom_controls.dart';
import 'package:chewie/chewie.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class CustomPlayer extends StatefulWidget {
  final List<dynamic> streams;
  final Function callback;
  final int initialPosition;
  final VoidCallback nextEpisode;
  final bool isLast;
  const CustomPlayer({
    super.key,
    required this.streams,
    required this.callback,
    required this.initialPosition,
    required this.nextEpisode,
    required this.isLast,
  });

  @override
  State<CustomPlayer> createState() => _CustomPlayerState();
}

class _CustomPlayerState extends State<CustomPlayer> {
  int? quality;
  bool hasLoaded = false;
  bool hasError = false;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _controller;

  int getPreferredQuality() {
    int preferredQuality = int.parse(
      Provider.of<Watchlist>(
        context,
        listen: false,
      ).preferredQuality,
    );
    final streams = widget.streams;
    int index = 0;
    for (int i = 0; i < streams.length; i++) {
      final check = int.parse(streams[i]["resolution"]);
      if (check == preferredQuality) {
        index = i;
        break;
      }
      if (check > preferredQuality) {
        index = i;
        break;
      } else {
        index = -1;
      }
    }
    if (index == -1) {
      index = streams.length - 1;
    }
    return index;
  }

  @override
  void initState() {
    int index = getPreferredQuality();
    initPlayer(
      index: index,
      position: Duration(
        seconds: widget.initialPosition,
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> toggleQuality(int index) async {
    _controller?.exitFullScreen();
    _controller?.videoPlayerController.pause();
    final position = await _controller?.videoPlayerController.position;
    setState(() {
      hasLoaded = false;
    });
    await initPlayer(index: index, position: position!);
    return;
  }

  Future<void> initPlayer({
    required Duration position,
    required int index,
  }) async {
    setState(() {
      quality = index;
    });
    var streams = widget.streams;

    streams = streams.map((item) {
      return {
        ...item,
        // "url":
        //     "${item["url"].toString().substring(0, 15)}files${item["url"].toString().substring(20)}",
        "url": item["url"].toString().replaceFirst("cache", "files"),
      };
    }).toList();

    final url = Uri.parse(streams[quality!]["url"]);

    _videoPlayerController = VideoPlayerController.contentUri(url);

    try {
      await _videoPlayerController!.initialize();
    } catch (error) {
      setState(() {
        hasError = true;
      });
    }

    _controller = customChewieController(
      streams: streams,
      position: position,
    );

    setState(() {
      hasLoaded = true;
    });
  }

  ChewieController customChewieController({
    Duration position = Duration.zero,
    required List<dynamic> streams,
  }) {
    return ChewieController(
      allowedScreenSleep: false,
      videoPlayerController: _videoPlayerController!,
      showControlsOnInitialize: true,
      autoPlay: true,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      customControls: CustomControls(
        callback: widget.nextEpisode,
        isLast: widget.isLast,
      ),
      startAt: position,
      maxScale: 2,
      aspectRatio: 16 / 9,
      materialProgressColors: ChewieProgressColors(
        backgroundColor: Colors.grey[900] as Color,
        bufferedColor: Colors.grey[300] as Color,
        handleColor: Theme.of(context).colorScheme.primary,
        playedColor: Theme.of(context).colorScheme.primary,
      ),
      additionalOptions: (context) => [
        OptionItem(
          onTap: () {
            Navigator.of(context).pop();
            showModalBottomSheet(
              context: context,
              builder: (context) => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...(streams).asMap().entries.map((item) {
                      int index = item.key;
                      final height = item.value["resolution"];
                      final audio = item.value["audio"];
                      final streamInfo = item.value["streamInfo"];

                      return ListTile(
                        leading: Icon(
                          Icons.check_rounded,
                          color: quality == index
                              ? Theme.of(context).colorScheme.onBackground
                              : Colors.transparent,
                        ),
                        title: Text("$streamInfo \u2022 $audio"),
                        onTap: () {
                          toggleQuality(index);
                          Navigator.of(context).pop();
                        },
                        trailing: height == 1080 || height == 720
                            ? Icon(
                                Icons.hd_outlined,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onBackground,
                              )
                            : null,
                      );
                    }),
                  ],
                ),
              ),
            );
          },
          iconData: Icons.settings,
          title: "Quality",
          subtitle: "${streams[quality!]["resolution"]}p",
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final position = await _controller!.videoPlayerController.position;
        await widget.callback(position: position?.inSeconds);
        return true;
      },
      child: hasError
          ? Container(
              alignment: Alignment.center,
              color: Theme.of(context).colorScheme.background,
              child: const Text(
                "Looks like the video is still processing,\n try again later",
                textAlign: TextAlign.center,
              ),
            )
          : hasLoaded
              ? Chewie(controller: _controller!)
              : Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
    );
  }
}
