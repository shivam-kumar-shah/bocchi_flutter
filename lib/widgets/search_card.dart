import 'package:anime_api/widgets/row_label.dart';
import 'package:flutter/material.dart';

import '../models/anime.dart';
import 'row_item.dart';

class SearchCard extends StatelessWidget {
  final VoidCallback callback;
  final Anime anime;
  const SearchCard({
    super.key,
    required this.anime,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          RowItem(
            anime: anime,
          ),
          RowLabel(title: anime.type),
        ],
      ),
    );
  }
}
