import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SvgAssetsPainter extends CustomPainter {
  final SvgPicture picture;
  final double scale;
  final Offset position;
  final double rotation;

  SvgAssetsPainter({
    required this.picture,
    required this.scale,
    required this.position,
    required this.rotation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // paint svg picture onto canvas
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.width / 2, -size.height / 2);
    canvas.translate(position.dx, position.dy);
    canvas.scale(scale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
