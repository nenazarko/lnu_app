import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/controllers/zoom.dart';
import 'package:lnu_nav_app/components/map/layers/base_layer.dart';
import 'package:lnu_nav_app/components/map/layers/custom_points.dart';
import 'package:lnu_nav_app/components/point_info/base.dart';
import 'package:lnu_nav_app/types/point.dart';

class PointsLayer extends CustomPointsLayer {
  void Function(Point)? onPointTap;
  PointsLayer({this.onPointTap}): super(points: []);

  @override
  BaseLayer setController(MapController controller) {
    super.setController(controller);
    return this;
  }

  @override
  void draw(Canvas canvas, Size size) {
    if (controller == null) return;
    points = controller!.currentFloorPoints ?? [];
    super.draw(canvas, size);
  }

  @override
  bool onTap(Offset position) {
    if (onPointTap == null) return false;
    // handle tap on badge
    // 1. get current floor badges
    final currentFloorPoints = controller!.currentFloorPoints;
    final tapPoint = tappedOnPoint(controller: controller!, points: currentFloorPoints, position: position);

    if (tapPoint != null) {
      onPointTap!(tapPoint);
    }

    return tapPoint != null;
  }
}

Offset tapPositionInScale(Offset position, ZoomController zc, {offsetY = 20, offsetX = 0}) {
  return Offset(
    (position.dx - zc.position.dx + offsetX) / zc.scale,
    (position.dy - zc.position.dy + offsetY) / zc.scale,
  );
}

Point? tappedOnPoint({
  required MapController controller,
  required List<Point> points,
  required Offset position,
  eps = 2000
}) {
  final currentFloorPoints = controller.currentFloorPoints;
  final zc = controller.zoomController;

  final tapPosition = tapPositionInScale(position, zc);
  final epsilon = eps / zc.scale;

  for (final point in currentFloorPoints) {
    final deltaX = point.x - tapPosition.dx;
    final deltaY = point.y - tapPosition.dy;

    if (math.pow(deltaX, 2) + math.pow(deltaY, 2) < epsilon) {
      return point;
    }
  }
  return null;
}