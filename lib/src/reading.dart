import 'dart:convert';

import 'package:biblos/main.dart';
import 'package:biblos/src/dictionary.dart';
import 'package:biblos/src/services/books.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReadingPage extends StatefulWidget {
  final String book;
  final String chapter;
  final double offset;
  const ReadingPage(
      {super.key,
      required this.book,
      required this.chapter,
      required this.offset});

  @override
  State<ReadingPage> createState() => ReadingPageState();
}

class ReadingPageState extends State<ReadingPage> {
  String chapter = "";
  Map? chapterData;
  Map? dictionary;

  Future fetchChapter(String c) async {
    final String response = await rootBundle
        .loadString("assets/books/${widget.book.replaceAll(" ", "_")}/$c.json");
    final result = jsonDecode(response) as Map;
    if (context.mounted) {
      setState(() {
        chapterData = result;
      });
    }
  }

  setChapter(String newChapter) async {
    setState(() {
      chapter = newChapter;
      chapterData = null;
    });
    fetchChapter(newChapter);
    bookmark(0);
  }

  void bookmark(double scrollOffset) {
    AppWidgetState.of(context)!.appData.setBookMark(
        newBook: widget.book, newChapter: chapter, newOffset: scrollOffset);
  }

  prevChapter() => setChapter((int.parse(chapter) - 1).toString());

  nextChapter() => setChapter((int.parse(chapter) + 1).toString());

  @override
  void initState() {
    super.initState();
    chapter = widget.chapter;
    fetchChapter(chapter);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: ColoredBox(
            color: themePrimary,
            child: InkWell(
              hoverColor: themePrimaryLight,
              child: const Align(
                alignment: Alignment(0, -.2),
                child: Text(
                  "β",
                  style: TextStyle(
                    fontSize: 24,
                    color: themeAccent,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
          title: Text("${widget.book} $chapter"),
          actions: [
            if (chapterData != null) ...[
              if (chapterData!["chapter"] != "1")
                IconButton(
                    onPressed: prevChapter, icon: const Icon(Icons.arrow_back)),
              if (int.parse(chapterData!["chapter"]) <
                  verseMap[widget.book]!.length)
                IconButton(
                    onPressed: nextChapter,
                    icon: const Icon(Icons.arrow_forward)),
            ],
          ],
        ),
        body: ChapterWidget(
          chapterData: chapterData,
          offset: widget.offset,
        ));
  }

  static ReadingPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<ReadingPageState>();
  }
}

class ChapterWidget extends StatefulWidget {
  final Map? chapterData;
  final double offset;
  const ChapterWidget(
      {super.key, required this.chapterData, required this.offset});

  @override
  State<ChapterWidget> createState() => ChapterWidgetState();
}

class ChapterWidgetState extends State<ChapterWidget> {
  ScrollController? _controller;
  Future? future;

  @override
  void initState() {
    _controller = ScrollController(initialScrollOffset: widget.offset);
    _controller?.addListener(onScroll);
    super.initState();
  }

  void onScroll() async {
    future ??= Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) {
        ReadingPageState.of(context)?.bookmark(_controller!.offset);
      }
      future = null;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = ReadingPageState.of(context)!.chapter;
    return ListView(controller: _controller, children: [
      ChapterSlider(
        chapter: chapter,
      ),
      if (widget.chapterData case Map<String, dynamic> chapterData)
        Padding(
            padding: const EdgeInsets.all(10),
            child: RichText(
                text: TextSpan(children: [
              for (var j = 1; j != chapterData["verses"].length; j++) ...[
                WidgetSpan(
                  child: Transform.translate(
                    offset: const Offset(0, -8), // Adjust the Y value as needed
                    child: Text(
                      "$j ",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                for (var greekword in chapterData["verses"][j.toString()])
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      wordSpacing: 8,
                      height: 2,
                    ),
                    text: '${greekword["gr"]} ${greekword["pu"] ?? ""} ',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        showBottomSheet(
                          context: context,
                          builder: (context) => BottomSheetWidget(
                            word: Map.from(greekword),
                            minimized: true,
                          ),
                        );
                      },
                  )
              ]
            ])))
    ]);
  }
}

class ChapterSlider extends StatefulWidget {
  final String chapter;
  const ChapterSlider({super.key, required this.chapter});

  @override
  State<ChapterSlider> createState() => ChapterSliderState();
}

class ChapterSliderState extends State<ChapterSlider> {
  int position = 1;

  @override
  void initState() {
    position = int.parse(widget.chapter);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChapterSlider oldWidget) {
    position = int.parse(widget.chapter);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: position.toDouble(),
      min: 1,
      max: verseMap[ReadingPageState.of(context)!.widget.book]!
          .length
          .toDouble(),
      divisions:
          verseMap[ReadingPageState.of(context)!.widget.book]!.length - 1,
      label: position.toString(),
      onChanged: (double value) {
        setState(() {
          position = value.toInt();
        });
      },
      onChangeEnd: (value) {
        ReadingPageState.of(context)!.setChapter(position.toString());
      },
    );
  }
}
