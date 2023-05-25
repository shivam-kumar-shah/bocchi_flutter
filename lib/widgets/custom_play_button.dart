// ignore_for_file: duplicate_import, implementation_imports

import 'package:flutter/material.dart';

import 'package:chewie/src/animated_play_pause.dart';
import 'package:flutter/material.dart';

//Extension of CenteredPlayButton from Material Controls

class CustomPlayButton extends StatelessWidget {
  const CustomPlayButton({
    Key? key,
    required this.backgroundColor,
    this.iconColor,
    required this.show,
    required this.isPlaying,
    required this.isFinished,
    required this.isLast,
    this.onPressed,
  }) : super(key: key);

  final Color backgroundColor;
  final Color? iconColor;
  final bool show;
  final bool isPlaying;
  final bool isFinished;
  final VoidCallback? onPressed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.transparent,
      child: Center(
        child: UnconstrainedBox(
          child: AnimatedOpacity(
            opacity: show ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
              ),
              // Always set the iconSize on the IconButton, not on the Icon itself:
              // https://github.com/flutter/flutter/issues/52980
              child: IconButton(
                iconSize: 32,
                padding: const EdgeInsets.all(12.0),
                icon: isFinished
                    ? (isLast
                        ? Icon(
                            Icons.replay,
                            color: iconColor,
                          )
                        : Icon(
                            Icons.skip_next_rounded,
                            color: iconColor,
                          ))
                    : AnimatedPlayPause(
                        color: iconColor,
                        playing: isPlaying,
                      ),
                onPressed: onPressed,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
