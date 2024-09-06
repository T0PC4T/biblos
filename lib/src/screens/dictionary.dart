import 'package:biblos/src/components/bottom.dart';
import 'package:biblos/src/components/error.dart';
import 'package:biblos/src/providers/dictionary.dart';
import 'package:biblos/src/providers/inflections.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class DictionaryPage extends StatelessWidget {
  final Map word;
  const DictionaryPage({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(word["gr"]),
        backgroundColor: themePrimary,
        foregroundColor: themeLight,
      ),
      body: SingleChildScrollView(
          child: BottomSheetWidget(minimized: false, word: word)),
    );
  }
}

class SynopsisWidget extends StatelessWidget {
  final Map word;
  const SynopsisWidget({
    super.key,
    required this.word,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
            text: '${word["gr"]}\t\t',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: themeDark),
          ),
          const WidgetSpan(
              child: Icon(
            Icons.volume_up_rounded,
            size: 16,
          )),
          TextSpan(
            text: ' ${word["tl"]}\n',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: 'meaning: ',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: themeDark, fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: '${word["en"]}\n',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: themePrimary, fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: 'synopsis: ',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: themeDark, fontStyle: FontStyle.italic),
          ),
          TextSpan(
            text: "${codeToWord(word["pa"]).trim()}\n",
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: themePrimary, fontWeight: FontWeight.bold),
          ),
        ]))
      ],
    );
  }
}

class FullDictionaryEntryWidget extends ConsumerWidget {
  final Map word;
  final String entry;
  const FullDictionaryEntryWidget({
    super.key,
    required this.word,
    required this.entry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lsDataProvider = ref.watch(lsjProvider(entry));
    final strongDataProvider = ref.watch(strongProvider(entry));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          decoration: const BoxDecoration(
            color: themeAccent,
            borderRadius: themeBorderRadius,
          ),
          margin: const EdgeInsets.only(bottom: 10),
          child: Text(
            "Strong $entry:",
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        strongDataProvider.when(
          data: (strongDatum) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${strongDatum["gr"]}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Speech: ${strongDatum["pos"]}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Meaning: ${strongDatum["df"]}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'Usage: ${strongDatum["us"]}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              lsDataProvider.when(
                data: (lsData) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lsData case String data when data.isNotEmpty) ...[
                        const Divider(
                          height: themePadding * 2,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: themePadding),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 5),
                            decoration: const BoxDecoration(
                              color: themeAccent,
                              borderRadius: themeBorderRadius,
                            ),
                            margin: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              "Liddell & Scott (${strongDatum["gr"]}):",
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ),
                        HtmlWidget(
                          data,
                          textStyle: const TextStyle(fontSize: 16),
                          customStylesBuilder: (element) {
                            return {'text-decoration': 'none'};
                          },
                        ),
                      ]
                    ],
                  );
                },
                error: ErrorBoxWidget.err,
                loading: loadingFunc,
              ),
            ],
          ),
          error: ErrorBoxWidget.err,
          loading: loadingFunc,
        ),
      ],
    );
  }
}
