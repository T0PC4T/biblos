import 'dart:async';

import 'package:biblos/src/providers/bookmarks.dart';
import 'package:biblos/src/providers/providers.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastMarkNotifier extends AutoDisposeAsyncNotifier<MarkedBook?> {
  Future<SharedPreferences> fprefs = SharedPreferences.getInstance();
  static const bookmarkKey = "bookmark";
  void save(MarkedBook markedBook) async {
    final SharedPreferences prefs = await fprefs;
    prefs.setString(bookmarkKey, markedBook.toString());
    // update watchers
    state = AsyncValue.data(markedBook);

    // update individual books notifier;
    ref.read(bookmarkNotifier.notifier).saveBookmark(markedBook);
  }

  @override
  FutureOr<MarkedBook?> build() async {
    final SharedPreferences prefs = await fprefs;
    if (prefs.get(bookmarkKey) case String bookmark) {
      if (bookmark.split(":")
          case [String book, String chapter, String verse]) {
        if (verseMap[book] case List<int> verses) {
          if (int.tryParse(chapter) case int chapter) {
            if (int.tryParse(verse) case int verse) {
              if (chapter >= 0 && chapter < verses.length) {
                if (verse >= 0 && verse < verses[chapter]) {
                  return MarkedBook(book, chapter, verse);
                }
              }
            }
          }
        }
      }
    }
    return null;
  }
}

final lastBookMarkNotifier =
    AsyncNotifierProvider.autoDispose<LastMarkNotifier, MarkedBook?>(
        LastMarkNotifier.new);
