import 'package:anime_api/widgets/preferences_modal.dart';

import '../widgets/bocchi_rich_text.dart';
import 'package:flutter/material.dart';

import '../helpers/http_helper.dart';
import '../widgets/row_sliver.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = "/";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Text(
                "Trending",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                "Recents",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                "Popular",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CustomScrollView(
              slivers: [
                RowSliver(
                  option: GetLanding.trending,
                ),
              ],
            ),
            CustomScrollView(
              slivers: [
                RowSliver(
                  option: GetLanding.recent,
                ),
              ],
            ),
            CustomScrollView(
              slivers: [
                RowSliver(
                  option: GetLanding.popular,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
