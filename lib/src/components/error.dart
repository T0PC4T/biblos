import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';

class ErrorBoxWidget extends StatelessWidget {
  const ErrorBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: themePaddingEdgeInset,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 185, 185),
        border: Border.all(
          width: 1,
          color: Colors.red,
        ),
        borderRadius: themeBorderRadius,
      ),
      child: const Text(
        "Something went wrong.\nCheck your internet connection and try again.",
        textAlign: TextAlign.center,
      ),
    );
  }

  static Widget err(Object error, StackTrace stack) {
    return Container(
      padding: themePaddingEdgeInset,
      alignment: Alignment.topCenter,
      child: const ErrorBoxWidget(),
    );
  }
}

Widget loadingFunc() => Container(
    padding: themePaddingEdgeInset,
    alignment: Alignment.center,
    child: const Text("Loading..."));
