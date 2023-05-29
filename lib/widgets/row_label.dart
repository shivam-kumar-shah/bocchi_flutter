import 'package:flutter/material.dart';

class RowLabel extends StatelessWidget {
  const RowLabel({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
