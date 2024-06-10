import 'dart:convert';

import 'package:biblos/src/dictionary.dart';
import 'package:biblos/src/services/ls.dart';
import 'package:biblos/src/static.dart';
import 'package:biblos/theme.dart';
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
    print("bookmarking ${widget.book} $chapter $scrollOffset");
    AppDataClass.setBookmark(
        book: widget.book, chapter: chapter, offset: scrollOffset);
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
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const ReadingDrawer(),
        appBar: AppBar(
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

class ReadingDrawer extends StatelessWidget {
  const ReadingDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final readingWidget = ReadingPageState.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: themePaddingEdgeInset,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton.filled(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "${readingWidget?.widget.book} ${readingWidget?.chapter}",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Divider(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tight(const Size(double.infinity, 50)),
                child: FilledButton.icon(
                  icon: const Icon(Icons.home),
                  onPressed: () => Navigator.popUntil(context, (route) {
                    return route.isFirst;
                  }),
                  label: const Text("Home"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tight(const Size(double.infinity, 50)),
                child: FilledButton.icon(
                  icon: const Icon(Icons.bookmark),
                  onPressed: () => Navigator.popUntil(context, (route) {
                    return route.isFirst;
                  }),
                  label: const Text("Add Bookmark"),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints.tight(const Size(double.infinity, 50)),
                child: FilledButton.icon(
                  icon: const Icon(Icons.book),
                  onPressed: () => Navigator.popUntil(context, (route) {
                    return route.isFirst;
                  }),
                  label: const Text("Greek Resources"),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(28, 16, 28, 10),
              child: Divider(),
            ),
          ],
        ),
      ),
    );
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
    return SingleChildScrollView(
      controller: _controller,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          children: [
            ChapterSlider(
              chapter: chapter,
            ),
            if (widget.chapterData != null) ...[
              for (var j = 1;
                  j != widget.chapterData!["verses"].length;
                  j++) ...[
                Text(
                  j.toString(),
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                for (var greekword in widget.chapterData!["verses"]
                    [j.toString()])
                  GestureDetector(
                    onTap: () {
                      showBottomSheet(
                        context: context,
                        builder: (context) => BottomSheetWidget(
                          word: Map.from(greekword),
                          minimized: true,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 8),
                      child: Text(
                        '${greekword["gr"]} ${greekword["pu"] ?? ""}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
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
