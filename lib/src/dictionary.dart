import 'dart:convert';

import 'package:biblos/src/shared.dart';
import 'package:biblos/src/static.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_html_css/simple_html_css.dart';

class BottomSheetWidget extends StatelessWidget {
  final Map word;
  final bool minimized;
  const BottomSheetWidget(
      {super.key, required this.word, required this.minimized});

  Widget getChild(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (minimized)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: Navigator.of(context).pop,
              child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  margin: const EdgeInsets.only(bottom: 20),
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
            padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${word["gr"]}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: 15,
                      ),
                    ),
                    Text(
                      '${word["tl"]}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Text(
                  '${word["en"]}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  codeToWord(word["pa"]),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Divider(),
                ),
                Text(
                  "From Strong ${word["st"]}:",
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                // Strong entry for the lexical word
                StrongEntryWidget(
                  word: word,
                  entry: word["st"],
                  minimized: minimized,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (minimized) {
      return getChild(context);
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text(word["gr"]),
        ),
        body: SingleChildScrollView(child: getChild(context)),
      );
    }
  }
}

class StrongEntryWidget extends StatefulWidget {
  final Map word;
  final String entry;
  final bool minimized;
  const StrongEntryWidget({
    super.key,
    required this.word,
    required this.entry,
    required this.minimized,
  });

  @override
  State<StrongEntryWidget> createState() => StrongEntryWidgetState();
}

class StrongEntryWidgetState extends State<StrongEntryWidget> {
  List<Map> strongData;

  StrongEntryWidgetState() : strongData = [];

  Future fetchStrong() async {
    // for (var letter in ["", "a", "b", "c"]) {
    for (var letter in [""]) {
      final filePath = "assets/Strong/${widget.word['st']}$letter.json";
      if (true) {
        final String response = await rootBundle.loadString(filePath);
        final result = jsonDecode(response) as Map;
        if (context.mounted) {
          setState(() {
            strongData.add(result);
          });
        }
      }
    }
  }

  @override
  void initState() {
    fetchStrong();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          if (widget.minimized == false)
            DictionaryEntryWidget(wordKey: strongDatum["gr"].split(",")[0])
          else
            Center(
              child: Padding(
                padding: themePaddingEdgeInset,
                child: ElevatedButton(
                  child: const Text("Dictionary"),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return BottomSheetWidget(
                            word: widget.word, minimized: false);
                      },
                    ));
                  },
                ),
              ),
            )
        ]
      ],
    );
  }
}

class DictionaryEntryWidget extends StatefulWidget {
  final String wordKey;
  const DictionaryEntryWidget({super.key, required this.wordKey});

  @override
  State<DictionaryEntryWidget> createState() => _DictionaryEntryWidgetState();
}

class _DictionaryEntryWidgetState extends State<DictionaryEntryWidget> {
  Map? dictionaryData;

  Future fetchDictionary() async {
    final String response =
        await rootBundle.loadString("assets/dictionary.json");

    final result = jsonDecode(response) as Map;
    if (context.mounted) {
      setState(() {
        dictionaryData = result;
      });
    }
  }

  @override
  void initState() {
    fetchDictionary();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (dictionaryData == null) {
      return const LoadingWidget();
    }
    if (dictionaryData![widget.wordKey] == null) {
      return Container(
        width: double.infinity,
        padding: themePaddingEdgeInset,
        alignment: Alignment.center,
        child: Text(
          "No further details.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: RichText(
        text: HTML.toTextSpan(context, dictionaryData![widget.wordKey]),
        //...
      ),
    );
  }
}

String codeToWord(String code) {
  // print(code);
  // TODO "Make sure you've got all the types of words."
  List<String?> parts = [];
  switch (code.split("-")) {
    case [String part]:
      {
        parts.add(partsOfSpeech[part]);
      }
    case [String part, String details]:
      {
        parts.add(partsOfSpeech[part]);
        if (part == "V") {
          parts.add(tense[details[0]]);
          parts.add(mood[details[1]]);
          parts.add(voice[details[2]]);
        } else if (part == "Adv") {
          parts.add(comparison[details[0]]);
        } else {
          parts.add(wordCase[details[0]]);
          if (int.tryParse(details[1]) != null) {
            parts.add(person[details[1]]);
            parts.add(number[details[2]]);
          } else if (int.tryParse(details[2]) != null) {
            parts.add(gender[details[1]]);
            parts.add(person[details[2]]);
            parts.add(number[details[3]]);
          } else {
            parts.add(gender[details[1]]);
            parts.add(number[details[2]]);
          }
        }
      }
    case [String part, String details, String details2]:
      {
        parts.add(partsOfSpeech[part]);
        if (part == "Adj") {
          // Comparative Adjective
          parts.add(wordCase[details[0]]);
          parts.add(gender[details[1]]);
          parts.add(number[details[2]]);
          parts.add(comparison[details2[0]]);
        }

        if (part == "V") {
          // Verb
          // Details One
          if (details == "M") {
            parts.add(mood[details[0]]);
            parts.add(person[details2[0]]);
            parts.add(number[details2[1]]);
          } else {
            parts.add(tense[details[0]]);
            parts.add(mood[details[1]]);
            if (details.length > 2) {
              parts.add(voice[details.substring(2)]);
            }

            //  Details Two
            if (details2.length == 3) {
              // participle
              parts.add(wordCase[details2[0]]);
              parts.add(gender[details2[1]]);
              parts.add(number[details2[2]]);
            } else {
              parts.add(person[details2[0]]);
              parts.add(number[details2[1]]);
            }
          }
        }
      }
  }
  if (parts.contains(null)) {
    throw "Invalid word $parts";
  }

  final smallcode = code
      .split("-")
      .sublist(1)
      .fold<String>("", (previousValue, element) => previousValue + element)
      .replaceAll("M/P", "P");

  if (code.split("-").length > 1 && smallcode.length != parts.length - 1) {
    throw "Parts are missing $smallcode $code $parts";
  }

  return parts.fold("", (previousValue, element) => "$previousValue$element ");
}
