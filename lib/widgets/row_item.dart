import 'package:provider/provider.dart';

import '../providers/user_preferences.dart';
import '../screens/details_screen.dart';
import '../widgets/hero_image.dart';
import 'package:flutter/material.dart';

class RowItem extends StatelessWidget {
  final Map<String, dynamic> title;
  final String image;
  final String id;
  final String tag;
  final bool disabled;
  final VoidCallback? callback;
  const RowItem({
    super.key,
    required this.title,
    required this.tag,
    required this.image,
    required this.id,
    this.disabled = false,
    this.callback,
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
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: GridTile(
          footer: GridTileBar(
            title: Text(
              title[prefferedTitle.name] ?? title[subtitle.name],
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
                  imageUrl: image,
                  tag: tag,
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () {
                      if (callback != null) callback!();
                      if (disabled) return;
                      Navigator.of(context).pushNamed(
                        DetailsScreen.routeName,
                        arguments: {
                          "id": id,
                          "image": image,
                          "tag": tag,
                        },
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
