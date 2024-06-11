import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/controllers/zoom.dart';
import 'package:lnu_nav_app/components/map/map.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'layers/base_layer.dart';

class MapPainter extends CustomPainter {
  final double rotation;
  final MapPicture picture;
  final BuildContext context;
  final MapController mapController;
  late final List<BaseLayer> _layers;

  bool hasPicture = false;

  MapPainter({
    required this.rotation,
    required this.mapController,
    required this.picture,
    required this.context,
    required List<BaseLayer> layers
  }) : super(repaint: Listenable.merge([
    mapController, mapController.zoomController
  ])) { // Some magic here to repaint on _zc change
    _layers = layers.map((layer) {
      layer.setPainter(this);
      return layer;
    }).toList();
  }
  
  ZoomController get _zc => mapController.zoomController;

  bool isPointInViewport(Point point, double epsilon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final canvasX = point.x * _zc.scale + _zc.position.dx;
    final canvasY = point.y * _zc.scale + _zc.position.dy;

    final isXInViewport =
        canvasX >= -epsilon && canvasX <= screenWidth + epsilon;
    final isYInViewport =
        canvasY >= -epsilon && canvasY <= screenHeight + epsilon;

    return isXInViewport && isYInViewport;
  }

  double getScale() {
    return _zc.scale;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    // canvas.translate(size.width / 2, size.height / 2);
    // TODO: add rotation
    // canvas.rotate(rotation);
    // canvas.translate(-size.width / 2, -size.height / 2);

    // draw part of image from state
    canvas.translate(_zc.position.dx, _zc.position.dy);
    canvas.scale(_zc.scale);

    for (final layer in _layers) {
      layer.setPainter(this);
      layer.draw(canvas, size);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(MapPainter oldDelegate) {
    final buildingChanged = mapController.currentBuilding != oldDelegate.mapController.currentBuilding;
    final floorChanged = mapController.currentFloor != oldDelegate.mapController.currentFloor;
    final scaleChanged = _zc.scale != oldDelegate._zc.scale;
    final positionChanged = _zc.position != oldDelegate._zc.position;
    final pictureChanged = picture != oldDelegate.picture;

    return pictureChanged || buildingChanged || floorChanged || scaleChanged || positionChanged;
  }
}
