import 'package:flutter/material.dart';

class BocchiRichText extends StatelessWidget {
  const BocchiRichText({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: "bocchi",
        children: const [
          TextSpan(
            text: ".",
            style: TextStyle(
              color: Colors.pinkAccent,
            ),
          ),
          TextSpan(text: "tv"),
        ],
        style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 24,
            ),
      ),
    );
  }
}
