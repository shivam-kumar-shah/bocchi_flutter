import 'package:chewie/chewie.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/source.dart';
import '../providers/user_preferences.dart';
import 'custom_controls.dart';

class CustomPlayer extends StatefulWidget {
  final List<Source> streams;
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
  late Source currentSource;
  bool hasLoaded = false;
  bool hasError = false;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _controller;

  @override
  void initState() {
    final resolution = Provider.of<Watchlist>(
      context,
      listen: false,
    ).preferredQuality;
    currentSource = widget.streams.firstWhere(
      (element) => element.resolution == resolution,
      orElse: () => widget.streams.last,
    );
    initPlayer(
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

  Future<void> toggleSource({required Source newSource}) async {
    if (newSource.url == currentSource.url) return;
    _controller?.exitFullScreen();
    _controller?.videoPlayerController.pause();
    final position = await _controller?.videoPlayerController.position;
    setState(() {
      currentSource = newSource;
      hasLoaded = false;
    });
    await initPlayer(position: position!);
    return;
  }

  Future<void> initPlayer({
    required Duration position,
  }) async {
    final streams = widget.streams;
    final url = Uri.parse(currentSource.url);

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
                  children: widget.streams.map((source) {
                    return ListTile(
                      leading: Icon(
                        Icons.check_rounded,
                        color: currentSource.url == source.url
                            ? Theme.of(context).colorScheme.onBackground
                            : Colors.transparent,
                      ),
                      title: Text(
                          "${source.fansubGroup} \u2022 ${source.audio} \u2022 ${source.resolution}"),
                      onTap: () {
                        toggleSource(newSource: source);
                        Navigator.of(context).pop();
                      },
                      trailing: source.resolution == "1080" ||
                              source.resolution == "720"
                          ? Icon(
                              Icons.hd_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onBackground,
                            )
                          : null,
                    );
                  }).toList(),
                ),
              ),
            );
          },
          iconData: Icons.settings,
          title: "Quality",
          subtitle: "${currentSource.resolution}p",
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
