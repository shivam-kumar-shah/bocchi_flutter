import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget {
  final Widget? title;
  final Widget image;
  const CustomAppBar({super.key, this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.3,
      pinned: true,
      stretch: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      primary: true,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        title: title,
        expandedTitleScale: 2,
        background: image,
      ),
    );
  }
}
