import 'dart:convert';

import 'package:flutter/services.dart';

abstract class JsonInterface<T> {
   T fromJson(Map<String, dynamic> json);
}

class JsonReader {
  static Future<Map<String, dynamic>> readJson(String path) async {
    final data = await rootBundle.loadString(path);
    return json.decode(data);
  }

  static Future<T> readFile<T extends JsonInterface>(String path, T struct) async {
    final data = await rootBundle.loadString(path);
    return readStr(data, struct);
  }

  static T readStr<T extends JsonInterface>(String str, T struct) {
    final map = json.decode(str);
    return struct.fromJson(map);
  }
}