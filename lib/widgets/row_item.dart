import 'package:provider/provider.dart';

import '../models/anime.dart';
import '../providers/user_preferences.dart';
import '../screens/details_screen.dart';
import '../widgets/hero_image.dart';
import 'package:flutter/material.dart';

class RowItem extends StatelessWidget {
  final Anime anime;
  const RowItem({
    super.key,
    required this.anime,
  });

  @override
  Widget build(BuildContext context) {
    final prefference = Provider.of<Watchlist>(context).prefferedTitle;

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: GridTile(
          footer: GridTileBar(
            title: Text(
              anime.title.prefTitle(prefference),
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
                  tag: anime.hashCode.toString(),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      if (anime.episodes == 0) return;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            anime: anime,
                            hash: anime.hashCode.toString(),
                          ),
                        ),
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
