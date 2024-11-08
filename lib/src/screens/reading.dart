import 'dart:ui';

import 'package:biblos/src/components/bottom.dart';
import 'package:biblos/src/components/error.dart';
import 'package:biblos/src/providers/bookmarks.dart';
import 'package:biblos/src/providers/books.dart';
import 'package:biblos/src/providers/lastmark.dart';
import 'package:biblos/src/providers/providers.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadingPage extends ConsumerStatefulWidget {
  final String book;
  final int chapter;
  final int verse;
  const ReadingPage(
      {super.key,
      required this.book,
      required this.chapter,
      required this.verse});

  @override
  ConsumerState<ReadingPage> createState() => ReadingPageState();
}

class ReadingPageState extends ConsumerState<ReadingPage> {
  int chapter = 1;
  int verse = 1;

  setChapter(int newChapter) async {
    setState(() {
      chapter = newChapter;
    });
    bookmark(1);
  }

  void bookmark(int verse) {
    ref.read(lastBookMarkNotifier.notifier).save(
          MarkedBook(widget.book, chapter, verse),
        );
  }

  prevChapter() => setChapter(chapter - 1).toString();

  nextChapter() => setChapter(chapter + 1).toString();

  @override
  void initState() {
    super.initState();
    chapter = widget.chapter;
    verse = widget.verse;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final providedBookData = ref.watch(booksProvider((
      book: widget.book,
      chapter: chapter,
    )));
    return Scaffold(
        appBar: AppBar(
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
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
          title: Text("${widget.book} $chapter"),
          actions: [
            if (providedBookData.valueOrNull != null) ...[
              if (chapter > 1)
                IconButton(
                  onPressed: prevChapter,
                  icon: const Icon(Icons.arrow_back),
                ),
              if (chapter < verseMap[widget.book]!.length)
                IconButton(
                  onPressed: nextChapter,
                  icon: const Icon(Icons.arrow_forward),
                ),
            ],
          ],
        ),
        body: providedBookData.when(
            error: ErrorBoxWidget.err,
            loading: loadingFunc,
            data: (chapterData) {
              return ChapterWidget(
                chapterData: chapterData,
                startingVerse: verse,
              );
            }));
  }

  static ReadingPageState? of(BuildContext context) {
    return context.findAncestorStateOfType<ReadingPageState>();
  }
}

class ChapterWidget extends StatefulWidget {
  final Map<dynamic, dynamic> chapterData;
  final int startingVerse;
  const ChapterWidget(
      {super.key, required this.chapterData, required this.startingVerse});

  @override
  State<ChapterWidget> createState() => ChapterWidgetState();
}

class ChapterWidgetState extends State<ChapterWidget> {
  ScrollController? _scrollController;
  GlobalKey<SynBottomSheetState> bottomSheetKey = GlobalKey();
  GlobalKey bodyKey = GlobalKey();
  Future? scrollFutureLock;
  Map? focusWord;

  @override
  void initState() {
    print("INTIATING WIDGET");
    _scrollController = ScrollController();
    _scrollController?.addListener(onScroll);
    SchedulerBinding.instance.addPostFrameCallback(
      (timeStamp) {
        // CONVERT VERSE LERP INTO SCROLL LERP
        if (ReadingPageState.of(context) case ReadingPageState readingState) {
          final totalVerse =
              verseMap[readingState.widget.book]![readingState.chapter - 1];
          final t = inverseLerp(
              widget.startingVerse.toDouble(), 1, totalVerse.toDouble());

          final total = bodyKey.currentContext?.size?.height ?? 1;
          final offset = lerpDouble(0, total, t)!;
          _scrollController?.animateTo(offset,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut);
        }
      },
    );
    super.initState();
  }

  double inverseLerp(double v, double min, double max) {
    if (v < min || v > max) {
      throw ArgumentError('Value $v is out of range [$min, $max]');
    }

    return (v - min) / (max - min);
  }

  void onScroll() async {
    // CONVERT SCROLL LERP INTO VERSE LERP
    scrollFutureLock ??=
        Future.delayed(const Duration(seconds: 1)).then((value) {
      if (mounted) {
        if (ReadingPageState.of(context) case ReadingPageState readingState) {
          final total = bodyKey.currentContext?.size?.height ?? 1;
          final current = _scrollController?.offset ?? 0;
          final t = inverseLerp(current, 0, total);
          final totalVerse =
              verseMap[readingState.widget.book]![readingState.chapter - 1];
          int verse = lerpDouble(1, totalVerse, t)!.toInt();
          readingState.bookmark(verse);
        }
      }
      scrollFutureLock = null;
    });
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chapter = ReadingPageState.of(context)!.chapter;
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(key: bodyKey, children: [
        ChapterSlider(
          chapter: chapter,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: RichText(
            text: TextSpan(
              children: [
                for (var j = 1;
                    j != widget.chapterData["verses"].length;
                    j++) ...[
                  WidgetSpan(
                    child: Transform.translate(
                      offset:
                          const Offset(-1, -8), // Adjust the Y value as needed
                      child: Text(
                        "$j ",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  for (var greekword in widget.chapterData["verses"]
                      [j.toString()])
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        wordSpacing: 8,
                        height: 2,
                      ),
                      text: '${greekword["gr"]} ${greekword["pu"] ?? ""} ',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          if (bottomSheetKey.currentContext?.mounted ?? false) {
                            bottomSheetKey.currentState
                                ?.updateWord(Map.from(greekword));
                          } else {
                            showBottomSheet(
                              context: context,
                              builder: (context) => SynBottomSheet(
                                key: bottomSheetKey,
                                word: Map.from(greekword),
                                minimized: true,
                              ),
                            );
                          }
                        },
                    )
                ]
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 50,
        ),
      ]),
    );
  }
}

class ChapterSlider extends StatefulWidget {
  final int chapter;
  const ChapterSlider({super.key, required this.chapter});

  @override
  State<ChapterSlider> createState() => ChapterSliderState();
}

class ChapterSliderState extends State<ChapterSlider> {
  int position = 1;

  @override
  void initState() {
    position = widget.chapter;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChapterSlider oldWidget) {
    position = widget.chapter;
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
        ReadingPageState.of(context)!.setChapter(position);
      },
    );
  }
}
