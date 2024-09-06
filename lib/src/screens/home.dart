import 'package:biblos/src/providers/bookmarks.dart';
import 'package:biblos/src/providers/lastmark.dart';
import 'package:biblos/src/providers/providers.dart';
import 'package:biblos/src/screens/bookmarks.dart';
import 'package:biblos/src/screens/bugs.dart';
import 'package:biblos/src/screens/reading.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  static HomePageState? of(BuildContext context) {
    return context.findAncestorStateOfType<HomePageState>();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: themePrimary,
        gradient: LinearGradient(
          colors: [themePrimary, themePrimaryAccent],
          begin: Alignment.centerLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text("βiblos", // ίβλος
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.headlineLarge),
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const BugsScreen()));
              },
              icon: const Icon(
                Icons.bug_report,
                color: themeAccent,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (c) => const BookMarksScreen()));
              },
              icon: const Icon(
                Icons.bookmark,
                color: themeAccent,
              ),
            )
          ],
        ),
        body: const Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            HomeTitleWidget(),
            Expanded(
              child: BookLibraryWidget(),
            ),
            // Add Widget
            // BannerAdContainer(),
          ],
        ),
      ),
    );
  }
}

class HomeTitleWidget extends ConsumerStatefulWidget {
  const HomeTitleWidget({
    super.key,
  });

  @override
  ConsumerState<HomeTitleWidget> createState() => HomeTitleWidgetState();
}

class HomeTitleWidgetState extends ConsumerState<HomeTitleWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastMark = ref.watch<AsyncValue<MarkedBook?>>(lastBookMarkNotifier);
    return Container(
      // margin: const EdgeInsets.all(themePadding),
      padding: themePaddingEdgeInset,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              if (lastMark.valueOrNull case MarkedBook lm) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReadingPage(
                    book: lm.book,
                    chapter: lm.chapter,
                    verse: lm.verse,
                  ),
                ));
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(20, 255, 255, 255),
                border: Border.all(width: strokeWidth, color: themeAccent),
                borderRadius: themeBorderRadius,
              ),
              margin: themePaddingEdgeInset,
              padding: themePaddingEdgeInset,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.book,
                    size: 48,
                    color: themeAccent,
                  ),
                  Padding(
                    padding: themePaddingEdgeInset,
                    child: Text(
                      lastMark.valueOrNull != null
                          ? "Continue reading:\n${lastMark.value!.pretty}"
                          : "Begin reading the\nGreek New Testament",
                      softWrap: true,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: themeAccent),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward,
                    size: 40,
                    color: themeAccent,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookLibraryWidget extends ConsumerWidget {
  const BookLibraryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchData = ref.watch(bookmarkNotifier);

    return Container(
      decoration: const BoxDecoration(
        color: themeLight,
        borderRadius: BorderRadius.only(
          topRight: themeCircularRadius,
          topLeft: themeCircularRadius,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: watchData.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => const Center(
                  child: Text(
                "Something went wrong",
                style: TextStyle(color: Colors.red),
              )),
          data: (chapterData) {
            return ListView(
              children: [
                for (var bookCategory in bookDivisionMap)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      top: themePadding * 2,
                      left: themePadding * 2,
                      right: themePadding * 2,
                    ),
                    padding: const EdgeInsets.all(themePadding),
                    decoration: BoxDecoration(
                      color: themeLight,
                      border: Border.all(
                        width: strokeWidth,
                        color: themePrimary,
                      ),
                      borderRadius: themeBorderRadius,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: themePaddingEdgeInset,
                          child: Text(
                            bookCategory.keys.first,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(color: themePrimary),
                          ),
                        ),
                        const SizedBox(height: themePadding / 2),
                        for (var book in bookCategory.values.first)
                          ListTile(
                            leading: const Icon(
                              Icons.menu_book_rounded,
                              size: 32,
                            ),
                            trailing: const Icon(Icons.arrow_forward),
                            title: Text(
                              book,
                              textAlign: TextAlign.start,
                            ),
                            subtitle: Text(chapterData[book]?.chapvers ?? ""),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ReadingPage(
                                    book: book,
                                    chapter: chapterData[book]?.chapter ?? 1,
                                    verse: chapterData[book]?.verse ?? 1,
                                  ),
                                ),
                              );
                              ref.read(lastBookMarkNotifier.notifier).save(
                                    MarkedBook(
                                      book,
                                      chapterData[book]?.chapter ?? 1,
                                      chapterData[book]?.verse ?? 1,
                                    ),
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                const Padding(padding: themePaddingEdgeInset),
              ],
            );
          }),
    );
  }
}
