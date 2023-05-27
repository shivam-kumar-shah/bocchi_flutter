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
                  anime.type,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
