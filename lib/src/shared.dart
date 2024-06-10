import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: themePaddingEdgeInset,
      alignment: Alignment.center,
      child: Text(
        "Loading...",
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
