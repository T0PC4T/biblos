import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataClass implements Listenable {
  String book = "Matthew";
  String chapter = "1";
  double offset = 0;

  Future initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    book = prefs.getString("book") ?? "Matthew";
    chapter = prefs.getString("chapter") ?? "1";
    offset = prefs.getDouble("offset") ?? 0;
  }

  void setBookMark({
    required String newBook,
    required String newChapter,
    required double newOffset,
  }) {
    print("bookmarking $book $chapter $offset");
    book = newBook;
    chapter = newChapter;
    offset = newOffset;
    notifyListeners();
    saveBookmark(book: newBook, chapter: newChapter, offset: newOffset);
  }

  Future<void> saveBookmark({
    required String book,
    required String chapter,
    required double offset,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("book", book);
    prefs.setString("chapter", chapter);
    prefs.setDouble("offset", offset);
  }

  void notifyListeners() {
    for (var listener in listeners) {
      listener.call();
    }
  }

  // TODO
  final listeners = [];

  @override
  void addListener(VoidCallback listener) {
    listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    listeners.remove(listener);
  }
}
