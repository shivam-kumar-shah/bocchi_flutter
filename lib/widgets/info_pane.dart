import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/anime.dart';
import '../providers/user_preferences.dart';

class InfoPane extends StatelessWidget {
  final Anime anime;
  const InfoPane({
    super.key,
    required this.anime,
  });

  @override
  Widget build(BuildContext context) {
    final prefference = Provider.of<Watchlist>(context).prefferedTitle;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          anime.title.prefTitle(prefference),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          anime.genres.join(" | "),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "${anime.season ?? ''} | ${anime.year != 0 ? anime.year.toString() : ''}",
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(
          height: 20,
        ),
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: InfoTile(
                field: anime.year != 0 ? anime.year.toString() : '',
                fieldTitle: "Year",
              ),
            ),
            InfoTile(
              field: anime.episodes.toString(),
              fieldTitle: "Episodes",
            ),
            Expanded(
              child: InfoTile(
                field: anime.status,
                fieldTitle: "Status",
              ),
            ),
          ],
        )
      ],
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    super.key,
    required this.field,
    required this.fieldTitle,
  });

  final String field;
  final String fieldTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          fieldTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          field,
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ],
    );
  }
}
