import 'package:flutter/material.dart';

import '../models/anime.dart';
import '../models/enums.dart';
import '../repositories/api_repo.dart';
import '../util/app_colors.dart';
import '../widgets/row_item.dart';

class RowSliver extends StatefulWidget {
  final GetLanding option;

  const RowSliver({super.key, required this.option});

  @override
  State<RowSliver> createState() => _RowSliverState();
}

class _RowSliverState extends State<RowSliver> {
  List<Anime>? fetchedData;
  bool hasError = false;
  String? errorMessage;

  void getData() async {
    try {
      setState(() {
        hasError = false;
      });
      final result = await APIRepository.getLanding(landing: widget.option);
      setState(() {
        fetchedData = result;
      });
    } catch (err) {
      setState(() {
        hasError = true;
        errorMessage = err.toString();
      });
    }
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return hasError
        ? SliverToBoxAdapter(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
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
                    onPressed: getData,
                    child: const Text("Refresh"),
                  ),
                ],
              ),
            ),
          )
        : fetchedData == null
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
                  anime: fetchedData![index],
                ),
                itemCount: fetchedData!.length,
              );
  }
}
