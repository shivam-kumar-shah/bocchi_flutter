import '../screens/search_screen.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          SearchScreen.routeName,
        );
      },
      heroTag: "Search Button",
      key: const ValueKey("Search Button"),
      tooltip: "Search",
      child: const Icon(
        Icons.search_outlined,
      ),
    );
  }
}
