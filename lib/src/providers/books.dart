import 'package:biblos/src/providers/api.dart';
import 'package:riverpod/riverpod.dart';

final booksProvider =
    FutureProvider.autoDispose.family<Map, ({String book, int chapter})>(
  (ref, input) async {
    final json = await apiGetJSON("books/${input.book}/${input.chapter}.json");
    if (json.data case Map data) {
      return data;
    }
    throw json.error;
  },
);
