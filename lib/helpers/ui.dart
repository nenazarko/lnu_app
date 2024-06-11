import 'package:flutter/foundation.dart';

class UiModel extends ChangeNotifier {
  bool fullScreenSearch = false;

  UiModel setFullScreenSearch(bool value) {
    fullScreenSearch = value;
    return this;
  }

  void commit() {
    notifyListeners();
  }
}
