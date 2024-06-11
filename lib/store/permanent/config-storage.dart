import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigStorage extends ChangeNotifier {
  static String? _structurePath;
  static String? _buildingId;
  static SharedPreferences? _prefs;

  static bool initialized = false;

  String? get structurePath => _structurePath;
  set structurePath(String? newStructurePath) {
    _structurePath = newStructurePath;
    _updateString('structurePath', newStructurePath);
  }

  String? get buildingId => _buildingId;
  set buildingId(String? newBuildingId) {
    _buildingId = newBuildingId;
    _updateString('buildingId', newBuildingId);
  }

  static Future<ConfigStorage> initialize() async {
    if (initialized) return ConfigStorage();
    _prefs = await SharedPreferences.getInstance();

    _structurePath = _prefs!.getString('structurePath');
    _buildingId = _prefs!.getString('buildingId');

    initialized = true;
    return ConfigStorage();
  }

  void reset() {
    buildingId = null;
    structurePath = null;
    notifyListeners();
  }

  Future<void> _updateString(String key, String? newValue) async {
    if (newValue != null) {
      await _prefs!.setString(key, newValue);
    } else {
      await _prefs!.remove(key);
    }
    notifyListeners();
  }
}