import 'package:provider/provider.dart';

import '../models/anime.dart';
import '../models/enums.dart';
import '../providers/user_preferences.dart';
import '../screens/details_screen.dart';
import '../widgets/hero_image.dart';
import 'package:flutter/material.dart';

class RowItem extends StatelessWidget {
  final Anime anime;
  final VoidCallback callback;
  const RowItem({
    super.key,
    required this.anime,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    final prefferedTitle = Provider.of<Watchlist>(context).prefferedTitle;
    if (prefferedTitle == PrefferedTitle.engTitle) {
    } else {}
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: GridTile(
          footer: GridTileBar(
            title: Text(
              anime.title.jpTitle,
              maxLines: 2,
              softWrap: true,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 13,
                  ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            backgroundColor: const Color.fromRGBO(0, 0, 0, 0.75),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: HeroImage(
                  imageUrl: anime.coverImg,
                  tag: anime.id,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      if (anime.episodes != 0) return;
                      callback();
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(anime: anime),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
