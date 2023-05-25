import 'package:flutter/material.dart';
import "package:cached_network_image/cached_network_image.dart";

class HeroImage extends StatelessWidget {
  final String imageUrl;
  final String tag;
  const HeroImage({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          key: ValueKey(
            tag,
          ),
          progressIndicatorBuilder: (context, url, loadingProgress) => Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
        ),
      ),
    );
  }
}
