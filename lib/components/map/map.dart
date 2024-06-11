import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/parser.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/gestures.dart';
import 'package:lnu_nav_app/helpers/path.dart';
import 'package:lnu_nav_app/types/structures.dart';

import 'layers/base_layer.dart';

class MapWidget extends StatefulWidget {
  final List<BaseLayer> layers;
  final MapController controller;

   MapWidget({
    super.key,
    required this.layers,
    required this.controller
  }) {
     for (final layer in layers) {
       layer.setController(controller);
     }
  }

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class MapPicture {
  final Size size;
  final DrawableRoot svg;

  MapPicture(this.size, this.svg);
}

class _MapWidgetState extends State<MapWidget> {
  Size _size = Size.zero;

  Future<MapPicture> loadSvgFromAsset(Floor floor) async {
    final svgString = await rootBundle.loadString(normalizeAssetsPath(floor.background));
    final svgPicture = await SvgParser().parse(svgString);
    // get svg size
    _size = svgPicture.viewport.size;
    return MapPicture(_size, svgPicture);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return FutureBuilder(
          future: loadSvgFromAsset(widget.controller.currentFloor),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!snapshot.hasData) {
              return Center(
                child: Text('Failed to load Map | ${normalizeAssetsPath(widget.controller.currentFloor.background)}'),
              );
            }

            return Center(
              child: MapGestureDetector(
                picture: snapshot.data!,
                mapSize: _size,
                controller: widget.controller,
                layers: widget.layers,
              ),
            );
          },
        );
      },
    );
  }
}
