import 'package:anime_api/providers/user_preferences.dart';
import 'package:anime_api/widgets/bocchi_rich_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../helpers/http_helper.dart';
import '../widgets/preferences_modal.dart';
import '../widgets/search_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const routeName = "/search";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isLoading = false;
  int page = 0;
  TextEditingController? _controller;
  final FocusNode _focusNode = FocusNode();
  Map<String, dynamic>? fetchedData;
  bool hasError = false;
  String? errorMessage;

  void fetchData(String query) async {
    try {
      setState(() {
        hasError = false;
        isLoading = true;
      });
      final response = await HttpHelper.searchApi(
        query: _controller!.text,
      );
      setState(() {
        isLoading = false;
        fetchedData = response;
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
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller!.dispose();
    _focusNode.dispose();
    super.dispose();
  }

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
        body: Flex(
          direction: Axis.vertical,
          children: [
            hasError
                ? Flexible(
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
                          onPressed: () => fetchData(_controller!.text),
                          child: const Text("Refresh"),
                        ),
                      ],
                    ),
                  )
                : isLoading
                    ? Flexible(
                        child: Center(
                          child: SpinKitThreeInOut(
                            color: Theme.of(context).colorScheme.primary,
                            size: 30,
                          ),
                        ),
                      )
                    : fetchedData == null
                        ? FutureBuilder(
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Flexible(
                                  child: SpinKitThreeBounce(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 20,
                                  ),
                                );
                              }
                              return Flexible(
                                child: ListView.builder(
                                  reverse: true,
                                  itemBuilder: (context, index) {
                                    final data =
                                        snapshot.data!.reversed.toList();
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      leading: const Icon(Icons.history),
                                      title: Text(
                                        data[index].toString(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.displayLarge,
                                      ),
                                      onTap: () {
                                        _controller?.text =
                                            data[index].toString();
                                        _focusNode.requestFocus();
                                      },
                                    );
                                  },
                                  itemCount: snapshot.data?.length,
                                ),
                              );
                            },
                            future: Provider.of<Watchlist>(
                              context,
                              listen: false,
                            ).fetchSearchHistory(),
                          )
                        : Flexible(
                            child: CustomScrollView(
                              slivers: [
                                if (fetchedData!["results"].length == 0)
                                  SliverToBoxAdapter(
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.8,
                                      child: Center(
                                        child: Text(
                                          "Sorry, nothing found!",
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge,
                                        ),
                                      ),
                                    ),
                                  ),
                                SliverGrid(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 250,
                                  ),
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final data =
                                          fetchedData!["results"][index];
                                      return SearchCard(
                                        callback: () =>
                                            FocusScope.of(context).unfocus(),
                                        title: data["title"],
                                        type: data["type"],
                                        image: data["image"],
                                        id: data["id"],
                                        disabled:
                                            data["status"] == "Not yet aired" ||
                                                data["malId"] == null,
                                      );
                                    },
                                    childCount: fetchedData!["results"].length,
                                  ),
                                ),
                              ],
                            ),
                          ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: TextField(
                focusNode: _focusNode,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 5,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded),
                  labelStyle: Theme.of(context).textTheme.displayLarge,
                  labelText: "Search",
                  floatingLabelStyle:
                      Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                ),
                controller: _controller,
                keyboardType: TextInputType.text,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                    ),
                textCapitalization: TextCapitalization.sentences,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  fetchData(_controller!.text);
                  final title = _controller!.text.trim().toLowerCase();
                  if (title.isNotEmpty) {
                    Provider.of<Watchlist>(
                      context,
                      listen: false,
                    ).addToSearchHistory(
                      title: _controller!.text.trim().toLowerCase(),
                    );
                  }
                },
              ),
            ),
          ],
        ));
  }
}
