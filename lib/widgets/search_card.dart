import 'package:flutter/material.dart';

import 'row_item.dart';

class SearchCard extends StatelessWidget {
  final VoidCallback callback;
  final String image;
  final String id;
  final Map<String, dynamic> title;
  final bool disabled;
  final String type;
  const SearchCard({
    super.key,
    required this.image,
    required this.id,
    required this.title,
    required this.disabled,
    required this.type,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        children: [
          RowItem(
            id: id,
            image: image,
            tag: id,
            title: title,
            disabled: disabled,
            callback: callback,
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
                  type,
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
