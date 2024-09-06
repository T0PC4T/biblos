import 'dart:convert';

import 'package:http/http.dart' as http;

const String baseAPIURL = "https://t0pc4t.github.io/biblosdata/";

const Map<String, String> baseHeaders = {
  "accept": "application/json",
  "Content-Type": "application/json",
};

Future<({dynamic data, dynamic error})> apiGetJSON(String path) async {
  final r = await http.get(
    Uri.parse("$baseAPIURL$path"),
    headers: {
      "accept": "application/json",
      "Content-Type": "application/json",
    },
  );
  print("GETTING JSON FROM ${"$baseAPIURL$path"} STATUS ${r.statusCode}");
  if (r.statusCode == 200) {
    return (data: jsonDecode(r.body), error: null);
  } else {
    return (data: null, error: "Unable to download content");
  }
}

Future<({dynamic data, dynamic error})> apiGetHTML(String path) async {
  final r = await http.get(
    Uri.parse("$baseAPIURL$path"),
    headers: {
      "accept": "text/html",
      "Content-Type": "text/html",
    },
  );
  print("GETTING HTML FROM ${"$baseAPIURL$path"} STATUS ${r.statusCode}");
  if (r.statusCode == 200) {
    return (data: r.body, error: null);
  } else {
    return (data: null, error: "Unable to download content");
  }
}
