import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/map_painter.dart';

abstract class BaseLayer {
  MapPainter? painter;
  MapController? controller;

  // tap handler (function that returns bool)
  bool onTap(Offset position) => false;

  BaseLayer();

  BaseLayer setPainter(MapPainter painter) {
    this.painter = painter;
    return this;
  }

  BaseLayer setController(MapController controller) {
    this.controller = controller;
    return this;
  }

  void draw(Canvas canvas, Size size);
}
