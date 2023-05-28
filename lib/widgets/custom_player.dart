import 'dart:async';

import 'package:anime_api/util/app_colors.dart';
import "package:flutter/material.dart";
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:provider/provider.dart';

import '../models/source.dart';
import '../providers/user_preferences.dart';

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

  MeeduPlayerController? _meeduPlayerController;
  StreamSubscription? _playerSubscription;

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
    initController();
    initPlayer(position: Duration(seconds: widget.initialPosition));
    setState(() {
      hasLoaded = true;
    });

    super.initState();
  }

  void initController() {
    final streams = widget.streams;
    _meeduPlayerController = MeeduPlayerController(
      colorTheme: AppColors.green,
      controlsStyle: ControlsStyle.primary,
      enabledButtons: const EnabledButtons(playBackSpeed: false),
      bottomRight: IconButton(
        tooltip: "Quality",
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => ListView.builder(
              itemBuilder: (context, index) {
                final source = streams[index];
                return ListTile(
                  leading: Icon(
                    Icons.check_rounded,
                    color: currentSource.url == source.url
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  title: Text(
                    "${source.fansubGroup} \u2022 ${source.audio} \u2022 ${source.resolution}p",
                  ),
                  onTap: () {
                    toggleSource(newSource: source);
                    Navigator.of(context).pop();
                  },
                  trailing:
                      source.resolution == "1080" || source.resolution == "720"
                          ? Icon(
                              Icons.hd_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.primary,
                            )
                          : null,
                );
              },
              itemCount: streams.length,
              shrinkWrap: true,
            ),
          );
        },
        icon: const Icon(Icons.settings),
      ),
    );

    _playerSubscription = _meeduPlayerController!.onPositionChanged.listen(
      (event) {
        widget.callback(event);
      },
    );
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _meeduPlayerController?.dispose();
    super.dispose();
  }

  Future<void> toggleSource({required Source newSource}) async {
    if (newSource.url == currentSource.url) return;
    final position = _meeduPlayerController!.position.value;
    setState(() {
      currentSource = newSource;
      hasLoaded = false;
    });
    await initPlayer(position: position);
    return;
  }

  Future<void> initPlayer({
    required Duration position,
  }) async {
    _meeduPlayerController!.setDataSource(
      DataSource(
        type: DataSourceType.network,
        source: currentSource.url,
      ),
      autoplay: true,
      seekTo: position,
    );
    setState(() {
      hasLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
              ? MeeduVideoPlayer(controller: _meeduPlayerController!)
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
