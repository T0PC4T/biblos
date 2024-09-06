import 'package:biblos/src/providers/api.dart';
import 'package:riverpod/riverpod.dart';

final strongProvider = FutureProvider.autoDispose.family<Map, String>(
  (ref, recordID) async {
    // SKIPPING for (var letter in ["", "a", "b", "c"]) {
    final json = await apiGetJSON("strong/$recordID.json");
    if (json.data case Map data) {
      return data;
    }
    throw json.error;
  },
);

final lsjProvider = FutureProvider.autoDispose.family<String, String>(
  (ref, recordID) async {
    final json = await apiGetHTML("LSJ/$recordID.html");
    if (json.data case String data) {
      return data;
    }
    throw json.error;
  },
);
