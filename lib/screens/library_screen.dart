import 'package:anime_api/widgets/bocchi_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_preferences.dart';
import '../widgets/preferences_modal.dart';
import '../widgets/row_item.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const BocchiRichText(),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const PreferencesModal(),
              );
            },
            icon: const Icon(
              Icons.more_vert_rounded,
            ),
          ),
        ],
      ),
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 5.0,
              top: 10,
              bottom: 5,
            ),
            child: Text(
              "Continue Watching",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
        Provider.of<Watchlist>(context).getHistory.isEmpty
            ? SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Center(
                    child: Text(
                      "Nothing to see here!",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              )
            : SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemExtent: 170,
                    itemBuilder: (context, index) {
                      final animeHistory = Provider.of<Watchlist>(context)
                          .getHistory
                          .reversed
                          .toList()[index];
                      return RowItem(
                        anime: animeHistory.anime,
                        callback: () {},
                      );
                    },
                    itemCount:
                        Provider.of<Watchlist>(context).getHistory.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
              ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 5.0,
              top: 10,
              bottom: 5,
            ),
            child: Text(
              "Your Watchlist",
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
        Provider.of<Watchlist>(context).getWatchlist.isEmpty
            ? SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: Center(
                    child: Text(
                      "Nothing to see here!",
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              )
            : SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final anime = Provider.of<Watchlist>(
                        context,
                      ).getWatchlist[index];
                      return RowItem(
                        anime: anime,
                        callback: () {},
                      );
                    },
                    itemCount:
                        Provider.of<Watchlist>(context).getWatchlist.length,
                    scrollDirection: Axis.horizontal,
                    itemExtent: 170,
                  ),
                ),
              ),
      ]),
    );
  }
}
