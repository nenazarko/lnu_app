import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/controllers/zoom.dart';
import 'package:lnu_nav_app/components/map/layers/base_layer.dart';
import 'package:lnu_nav_app/components/map/map.dart';
import 'package:lnu_nav_app/components/map/map_painter.dart';
import 'package:lnu_nav_app/components/point_info/base.dart';
import 'package:lnu_nav_app/helpers/matrix.dart';
import 'package:lnu_nav_app/store/structure-data.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:matrix_gesture_detector/matrix_gesture_detector.dart';
import 'package:provider/provider.dart';

class MapGestureDetector extends StatefulWidget {
  final MapPicture picture;
  final Size mapSize;
  final List<BaseLayer> layers;
  final MapController controller;

  const MapGestureDetector({
    Key? key,
    required this.picture,
    required this.mapSize,
    required this.layers,
    required this.controller,
  }) : super(key: key);

  @override
  State<MapGestureDetector> createState() => _MapGestureDetectorState();
}

class _MapGestureDetectorState extends State<MapGestureDetector> {
  bool didFirstMount = false;

  ZoomController get _zc => widget.controller.zoomController;

  // make something like constructuor to add listener on zoomController to handle scheduled change
  @override
  void initState() {
    super.initState();
    _zc.addListener(handlePendingZoom);
  }

  @override
  void dispose() {
    _zc.removeListener(handlePendingZoom);
    super.dispose();
  }

  void handlePendingZoom() {
    final pendingChange = _zc.pendingChange;
    if (pendingChange == null) return;

    final position = pendingChange.position;
    if (position == null) return;

    _zc.pendingChange = null;

    zoomTo(position.dx, position.dy, pendingChange.scale);
  }

  final double _rotation = 0;

  void handleTap(Offset position) {
    for (final layer in widget.layers) {
      if (layer.onTap(position)) return;
    }
  }

  void centerMap() {
    final widthScale = MediaQuery.of(context).size.width / widget.mapSize.width;
    final heightScale = MediaQuery.of(context).size.height / widget.mapSize.height;
    // min scale
    _zc.scale = math.min(widthScale, heightScale);
    // center map
    _zc.position = Offset(
      (MediaQuery.of(context).size.width - widget.mapSize.width * _zc.scale) / 2,
      (MediaQuery.of(context).size.height - 230 - widget.mapSize.height * _zc.scale) / 2,
    );
  }

  /// Scale in PX
  void zoomTo(double x, double y, double? scale) {
    // x and y are in normal coordinates (not scaled)
    // so we need to:
    // 1. scale it
    // 2. fix x and y for new scale
    // 3. set new scale and position

    // 1. scale it
    var newScale = scale ?? _zc.scale;

    final widthRatio = MediaQuery.of(context).size.width / widget.mapSize.width;
    final heightRatio = MediaQuery.of(context).size.height / widget.mapSize.height;

    final min = math.min(widthRatio, heightRatio);
    const max = 2.0;

    _zc.scale = newScale.clamp(min, max);

    // 2. fix x and y for new scale
    final newX = x * _zc.scale;
    final newY = y * _zc.scale;

    // 3. set new scale and position
    _zc.position = Offset(
      MediaQuery.of(context).size.width / 2 - newX,
      MediaQuery.of(context).size.height / 2 - newY,
    );
  }

  // on mounted
  @override
  Widget build(BuildContext context) {
    if (mounted && !didFirstMount) {
      didFirstMount = true;
      if (_zc.centerOnStart) {
        centerMap();
      }
      handlePendingZoom();
    }

    return GestureDetector(
      onTapDown: (details) {
        handleTap(details.localPosition);
      },
      child: MatrixGestureDetector(
        onMatrixUpdate: (Matrix4 matrix, Matrix4? translationDeltaMatrix,
            Matrix4? scaleUpdateMatrix, Matrix4? rotationUpdateMatrix) {
          if (translationDeltaMatrix != null) {
            final translationDelta = translationDeltaMatrix.getTranslation();
            _zc.position = Offset(
              _zc.position.dx + translationDelta.x,
              _zc.position.dy + translationDelta.y,
            );
          }

          if (scaleUpdateMatrix != null) {
            final deltaUpscale = scaleUpdateMatrix.getMaxScaleOnAxis();
            final deltaDownscale = getMinScaleOnAxis(scaleUpdateMatrix);
            final deltaScale =
            deltaUpscale != 1.0 ? deltaUpscale : deltaDownscale;

            if (deltaScale != 1.0) {
              final newScale = deltaScale * _zc.scale;

              final min =
                  MediaQuery.of(context).size.width / widget.mapSize.width;
              const max = 2.0;

              if (newScale < min) {
                _zc.scale = min;
              } else if (newScale > max) {
                _zc.scale = max;
              } else {
                // preserve center on scale
                final center = Offset(
                  context.size!.width / 2,
                  context.size!.height / 2,
                );
                _zc.position =
                    center - (center - _zc.position) * (newScale / _zc.scale);
                _zc.scale = newScale;
              }
            }
          }
        },
        child: RepaintBoundary(
          child: CustomPaint(
            isComplex: true,
            willChange: false,
            painter: MapPainter(
              mapController: widget.controller,
              picture: widget.picture,
              rotation: _rotation,
              context: context,
              layers: widget.layers,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}
