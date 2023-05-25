import 'package:anime_api/providers/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPane extends StatelessWidget {
  final Map<String, dynamic> title;
  final int releaseDate;
  final List<dynamic> genres;
  final String? season;
  final String episodes;
  final String status;
  const InfoPane({
    super.key,
    required this.title,
    required this.releaseDate,
    required this.genres,
    this.season,
    required this.episodes,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final prefferedTitle = Provider.of<Watchlist>(context).prefferedTitle;
    PrefferedTitle subtitle;
    if (prefferedTitle == PrefferedTitle.english) {
      subtitle = PrefferedTitle.romaji;
    } else {
      subtitle = PrefferedTitle.english;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title[prefferedTitle.name] ?? title[subtitle.name] ?? "Unknown",
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          genres.join(" | "),
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
          "${season ?? ''} | ${releaseDate != 0 ? releaseDate.toString() : ''}",
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
                field: releaseDate != 0 ? releaseDate.toString() : '',
                fieldTitle: "Year",
              ),
            ),
            InfoTile(
              field: episodes,
              fieldTitle: "Episodes",
            ),
            Expanded(
              child: InfoTile(
                field: status,
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
