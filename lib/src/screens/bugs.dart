import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';

class BugsScreen extends StatelessWidget {
  const BugsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporting Bugs"),
        leading: ColoredBox(
          color: themePrimary,
          child: InkWell(
            hoverColor: themePrimaryLight,
            child: Align(
              alignment: const Alignment(0, -.2),
              child: Text(
                "β",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(themePadding * 2),
        padding: const EdgeInsets.all(themePadding * 2),
        decoration: BoxDecoration(
          color: themeLight,
          border: Border.all(
            width: strokeWidth,
            color: themePrimary,
          ),
          borderRadius: themeBorderRadius,
        ),
        child: Text(
          "To report a bug in the app or to suggest an improvement, please email my developer email address: t0pc4tdev@gmail.com.\n\nPlease be aware that this project is free and open source, meaning that development time is limited.\n\nI created Biblos to help spread the gospel message and I hope it aids you in understanding the gospels more easily.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
