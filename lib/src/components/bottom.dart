import 'package:biblos/src/screens/dictionary.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';

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
            mainAxisSize: MainAxisSize.min,
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
                FullDictionaryEntryWidget(
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
