import 'package:shared_preferences/shared_preferences.dart';

abstract class AppDataClass {
  static Future<({String? book, String? chapter, double? offset})>
      getBookmark() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return (
      book: prefs.getString("book"),
      chapter: prefs.getString("chapter"),
      offset: prefs.getDouble("offset"),
    );
  }

  static Future<void> setBookmark({
    required String book,
    required String chapter,
    required double offset,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("book", book);
    prefs.setString("chapter", chapter);
    prefs.setDouble("offset", offset);
  }
}
