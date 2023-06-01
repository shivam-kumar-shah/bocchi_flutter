import 'package:anime_api/providers/landing_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../util/app_colors.dart';
import '../widgets/row_item.dart';

class RowSliver extends StatefulWidget {
  final GetLanding option;

  const RowSliver({super.key, required this.option});

  @override
  State<RowSliver> createState() => _RowSliverState();
}

class _RowSliverState extends State<RowSliver> {
  @override
  Widget build(BuildContext context) {
    try {
      final animeList = Provider.of<LandingProvider>(context).getData(
        landing: widget.option,
      );
      return animeList.isEmpty
          ? SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 280,
              ),
              itemBuilder: (context, index) => RowItem(
                anime: animeList[index],
              ),
              itemCount: animeList.length,
            );
    } catch (err) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  err.toString(),
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightblack,
                  foregroundColor: AppColors.green,
                  minimumSize: const Size(150, 45),
                ),
                onPressed: () =>
                    Provider.of<LandingProvider>(context, listen: false)
                        .getData(landing: widget.option),
                child: const Text("Refresh"),
              ),
            ],
          ),
        ),
      );
    }
  }
}
