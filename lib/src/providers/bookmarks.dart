import 'dart:async';
import 'dart:convert';

import 'package:biblos/src/providers/providers.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarkedBook {
  String book;
  int chapter;
  int verse;

  String get chapvers {
    if (chapter == 1 && verse == 1) {
      return "Start at the beginning";
    }
    return "chapter $chapter, verse $verse";
  }

  @override
  String toString() {
    return "$book:$chapter:$verse";
  }

  String get pretty => "$book $chapter:$verse";

  MarkedBook(this.book, this.chapter, this.verse);
  bool get isBeginning => chapter == 1 && verse == 1;

  static Iterable<MarkedBook> bookmarksFromMap(Map data) sync* {
    for (var book in verseMap.keys) {
      if (data.containsKey(book)) {
        if (data[book]!.split(":") case [String chapter, String verse]) {
          if (int.tryParse(chapter) case int chapter) {
            if (int.tryParse(verse) case int verse) {
              yield MarkedBook(book, chapter, verse);
              continue;
            }
          }
        }
      }

      yield MarkedBook(book, 1, 1);
    }
  }

  static Map<String, String> mapFromBookmarks(Iterable<MarkedBook> bookmarks) {
    return {
      for (var bookmark in bookmarks)
        bookmark.book: "${bookmark.chapter}:${bookmark.verse}",
    };
  }
}

class BookMarksNotifier
    extends AutoDisposeAsyncNotifier<Map<String, MarkedBook>> {
  Future<SharedPreferences> fprefs = SharedPreferences.getInstance();
  Map<String, String> get defaultJSON => {
        for (var book in verseMap.keys) book: "1:1",
      };

  Future<void> saveBookmark(MarkedBook markedBook) async {
    final SharedPreferences prefs = await fprefs;
    if (state.valueOrNull?.values case Iterable<MarkedBook> bookmarksn) {
      bookmarksn.firstWhere(
        (element) => element.book == markedBook.book,
      )
        ..chapter = markedBook.chapter
        ..verse = markedBook.verse;
      state = AsyncValue.data(
        {
          for (var book in bookmarksn) book.book: book,
        },
      );
      prefs.setString(
        "bookmarkData",
        jsonEncode(
          MarkedBook.mapFromBookmarks(bookmarksn),
        ),
      );
    }
  }

  @override
  FutureOr<Map<String, MarkedBook>> build() async {
    final SharedPreferences prefs = await fprefs;
    if (prefs.getString("bookmarkData") case String response) {
      if (jsonDecode(response) case Map data) {
        return {
          for (var book in MarkedBook.bookmarksFromMap(data)) book.book: book,
        };
      }
    }
    return {
      for (var book in MarkedBook.bookmarksFromMap(defaultJSON))
        book.book: book,
    };
  }
}

final bookmarkNotifier = AsyncNotifierProvider.autoDispose<BookMarksNotifier,
    Map<String, MarkedBook>>(BookMarksNotifier.new);
