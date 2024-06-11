import 'package:flutter/material.dart';

class PendingZoom {
  double? scale;
  Offset? position;

  PendingZoom(this.scale, this.position);
}

class ZoomController extends ChangeNotifier {
  bool centerOnStart;
  late double _scale;
  late Offset _position;

  PendingZoom? pendingChange;

  double get scale => _scale;
  Offset get position => _position;

  set scale(double scale) {
    _scale = scale;
    notifyListeners();
  }

  set position(Offset position) {
    _position = position;
    notifyListeners();
  }

  schedule({double? scale, Offset? position}) {
    pendingChange = PendingZoom(scale, position);
    notifyListeners();
  }

  ZoomController({double scale = 1, Offset position = Offset.zero, this.centerOnStart = true}) {
    _scale = scale;
    _position = position;
  }
}