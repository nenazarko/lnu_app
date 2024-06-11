// layer 1

import 'dart:ui';

import 'package:lnu_nav_app/components/map/layers/base_layer.dart';
import 'package:lnu_nav_app/components/map/map_painter.dart';

class WallsLayer extends BaseLayer {
  WallsLayer();

  @override
  void draw(Canvas canvas, Size size) {
    if (painter == null) {
      return;
    }

    final image = painter!.picture;
    Size imageSize = image.size;
    final svg = image.svg;

    svg.draw(canvas, Rect.fromLTWH(0, 0, imageSize.width, imageSize.height));
  }
}
