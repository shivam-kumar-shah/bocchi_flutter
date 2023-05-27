import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/episode.dart';

class CustomTile extends StatelessWidget {
  final Episode episode;

  const CustomTile({
    super.key,
    required this.episode,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(episode.createdAt ?? '');
    return Flex(
      key: key,
      direction: Axis.horizontal,
      mainAxisSize: MainAxisSize.max,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Card(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: CachedNetworkImage(
                imageUrl: episode.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Episode ${episode.episode}",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                Text(
                  DateFormat.yMMMd("en_US").format(date),
                  maxLines: 2,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
