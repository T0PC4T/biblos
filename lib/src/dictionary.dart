import 'dart:convert';

import 'package:biblos/src/services/inflections.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class BottomSheetWidget extends StatelessWidget {
  final Map word;
  final bool minimized;
  const BottomSheetWidget(
      {super.key, required this.word, required this.minimized});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (minimized)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: Navigator.of(context).pop,
            child: Container(
                color: Theme.of(context).colorScheme.primary,
                alignment: Alignment.center,
                width: double.infinity,
                height: 30,
                child: Icon(
                  size: 30,
                  Icons.arrow_drop_down,
                  fill: 1,
                  color: Theme.of(context).colorScheme.onPrimary,
                )),
          ),
        Padding(
          padding: themePaddingEdgeInset,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SynopsisWidget(word: word),
              const Divider(
                height: themePadding * 2,
              ),
              if (minimized == true)
                ElevatedButton(
                  child: const Text("View Full Entry"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return DictionaryPage(word: word);
                      },
                    ));
                  },
                ),
              if (minimized == false)
                StrongEntryWidget(
                  word: word,
                  entry: word["st"],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class SynopsisWidget extends StatelessWidget {
  const SynopsisWidget({
    super.key,
    required this.word,
  });

  final Map word;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          text: ' ${word["tl"]}\n\n',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextSpan(
          text: 'meaning: ',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: themeDark, fontStyle: FontStyle.italic),
        ),
        TextSpan(
          text: '${word["en"]}\n\n',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(color: themeDark, fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: "~${codeToWord(word["pa"]).trim()}",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ]))
    ]);
  }
}

class StrongEntryWidget extends StatefulWidget {
  final Map word;
  final String entry;
  const StrongEntryWidget({
    super.key,
    required this.word,
    required this.entry,
  });

  @override
  State<StrongEntryWidget> createState() => StrongEntryWidgetState();
}

class StrongEntryWidgetState extends State<StrongEntryWidget> {
  List<Map> strongData;
  String? lsData;

  StrongEntryWidgetState() : strongData = [];

  Future fetchStrong() async {
    // for (var letter in [""]) {
    for (var letter in ["", "a", "b", "c"]) {
      final filePath = "assets/strong/${widget.word['st']}$letter.json";
      try {
        final String response = await rootBundle.loadString(filePath);
        final result = jsonDecode(response) as Map;
        if (context.mounted) {
          setState(() {
            strongData.add(result);
          });
        }
      } catch (e) {
        // file is not found but that's ok
      }
    }
  }

  Future fetchLSJ() async {
    final filePath = "assets/LSJ/${widget.word['st']}.html";
    try {
      final String response = await rootBundle.loadString(filePath);
      if (context.mounted) {
        setState(() {
          lsData = response;
        });
      }
    } catch (e) {
      // file not found also fine
    }
  }

  @override
  void initState() {
    fetchStrong();
    fetchLSJ();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.entry);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From Strong ${widget.entry}:",
          style: Theme.of(context).textTheme.labelSmall,
        ),
        for (var strongDatum in strongData) ...[
          Text(
            '${strongDatum["gr"]}',
            style: Theme.of(context).textTheme.headlineSmall,
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
          if (lsData case String data when data.isNotEmpty) ...[
            const Divider(
              height: themePadding * 2,
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: themePadding),
              child: Text(
                "From Liddell & Scott (${strongDatum["gr"]}):",
                style: Theme.of(context).textTheme.labelSmall,
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
        ]
      ],
    );
  }
}
