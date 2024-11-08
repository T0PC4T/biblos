import 'package:biblos/src/components/error.dart';
import 'package:biblos/src/providers/bookmarks.dart';
import 'package:biblos/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookMarksScreen extends ConsumerWidget {
  const BookMarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookMarks = ref.watch(bookmarkNotifier);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookmarks"),
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
      body: Padding(
        padding: const EdgeInsets.all(themePadding),
        child: SingleChildScrollView(
          child: bookMarks.when(
            data: (data) {
              final allBookmarks = data.keys.where(
                (e) {
                  return data[e]?.chapter != 1 || data[e]?.verse != 1;
                },
              ).toList();
              return Column(
                children: [
                  if (allBookmarks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(themePadding * 2),
                        child: Text("You have no bookmarks!"),
                      ),
                    ),
                  for (var bookmark in allBookmarks)
                    Padding(
                      padding: themePaddingEdgeInset,
                      child: ListTile(
                        leading: const Icon(Icons.bookmark),
                        title: Text(bookmark.toString()),
                        subtitle: Text(data[bookmark]!.pretty),
                        trailing: const Text("Delete"),
                        onTap: () {
                          ref
                              .read(bookmarkNotifier.notifier)
                              .saveBookmark(MarkedBook(bookmark, 1, 1));
                        },
                      ),
                    )
                ],
              );
            },
            error: ErrorBoxWidget.err,
            loading: loadingFunc,
          ),
        ),
      ),
    );
  }
}
