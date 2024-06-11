// layer 1

import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:lnu_nav_app/components/layouts/route_layout/layout.dart';
import 'package:lnu_nav_app/components/map/layers/base_layer.dart';
import 'package:lnu_nav_app/variables.dart';

class RouteLayer extends BaseLayer {
  final RouteData? routeData;
  RouteLayer(this.routeData);

  @override
  void draw(Canvas canvas, Size size) {
    if (painter == null) return;
    if (controller == null) return ;
    if (routeData == null) return;

    final route = routeData!.currentFloorPoints;
    final scale = controller!.zoomController.scale;
    final strokeWidth = (20 / scale).clamp(10, 25).toDouble();

    final paint = Paint()
      ..color = const Color(0xFF14DEB7).withAlpha(160)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // draw route
    // we must make sure that line joins are rounded
    // so we need to draw each segment separately
    // and connect them with rounded joints

    for (var i = 0; i < route.length - 1; i++) {
      final start = route[i];
      final end = route[i + 1];

      final segment = Path()
        ..moveTo(start.x, start.y)
        ..lineTo(end.x, end.y);

      path.addPath(segment, Offset.zero);
    }

    canvas.drawPath(path, paint);

    // draw start and end points
    final start = route.first;
    final end = route.last;

    final endInnerCircleSize = (10 / scale).clamp(10, 20).toDouble();
    final innerCircleSize = (10 / scale).clamp(5, 10).toDouble();

    paint.color = const Color(0xFF14DEB7);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(start.x, start.y), innerCircleSize, paint);
    canvas.drawCircle(Offset(end.x, end.y), endInnerCircleSize, paint);

    final outerCircleSize = (20 / scale).clamp(10, 20).toDouble();
    paint.color = const Color(0xFF14DEB7);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(end.x, end.y), outerCircleSize, paint);

    // draw icon with poi
    for (final poi in routeData!.poi) {
      if (!route.contains(poi.point)) continue;
      if (poi.kind != 'stairs') continue;
      if (poi.point == route.first) continue;

      // draw Material poi icon with text
      final iconSize = (30 / scale).clamp(15, 30).toDouble();
      final icon = poi.icon;
      TextPainter textPainter = TextPainter(textDirection: TextDirection.rtl);
      textPainter.text = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(fontSize: iconSize,fontFamily: icon.fontFamily, color: Colors.white)
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(poi.point.x - iconSize / 2, poi.point.y - iconSize / 2));
    }
  }
}
