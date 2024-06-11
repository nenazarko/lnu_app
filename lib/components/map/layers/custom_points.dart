import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/components/map/controllers/zoom.dart';
import 'package:lnu_nav_app/components/map/layers/base_layer.dart';
import 'package:lnu_nav_app/extensions/hex_color.dart';
import 'package:lnu_nav_app/store/map-data.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/variables.dart';
import 'package:provider/provider.dart';

class CustomPointsLayer extends BaseLayer {
  late List<Point> points;
  final iconWC = SvgPicture.asset('assets/wc.svg', width: 30, height: 30);

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );


  CustomPointsLayer({
    required this.points,
  });

  ZoomController get _zc => controller!.zoomController;

  void drawRoutePoint(Canvas canvas, Size size, Point point) {
    if (painter == null) return;

    final paint = Paint()
      ..color = const Color(0xFF14DEB7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;

    paint.color = const Color(0xFF14DEB7);
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(Offset(point.x, point.y), 5, paint);

    paint.color = const Color(0xFF14DEB7);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(Offset(point.x, point.y), 10, paint);
  }

  void drawFlatPoint(Canvas canvas, Size size, Point point) {
    final scale = _zc.scale;
    double fontSize = 13 / scale;

    // if (scale >= 6) return;
    final textSpan = TextSpan(
      text: point.label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: fontSize.clamp(18, 32),
        fontFamily: GoogleFonts.russoOne().fontFamily,
      ),
    );

    textPainter.text = textSpan;
    textPainter.layout();
    textPainter.paint(
      canvas,
      // center at the point
      Offset(point.x - textPainter.width / 2, point.y - textPainter.height / 2),
    );
  }

  double __badgeSize(Canvas canvas) {
    final scale = _zc.scale;
    double badgeSize = scale > 0.2 ? 30 / scale : 15 / scale;
    if (scale >= 0.35) badgeSize = 30 / scale;
    return badgeSize;
  }

  void drawPinPoint(Canvas canvas, Size size, Point point) {
    final scale = _zc.scale;
    double badgeSize = __badgeSize(canvas).clamp(23, 55);
    //
    const icon = Icons.location_pin;
    TextPainter badgePainter =
        TextPainter(textDirection: TextDirection.rtl, maxLines: 1);
    badgePainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: badgeSize.clamp(23, 55),
            fontFamily: icon.fontFamily,
            color: point.color != null
                ? HexColor.fromHex(point.color!) ?? Colors.purple
                : Colors.purple));
    badgePainter.layout();
    badgePainter.paint(
        canvas,
        Offset(
            point.x - badgePainter.width / 2, point.y - badgePainter.height));

    if (scale <= 0.2) return;

    // compute from badge size
    double fontSize = badgeSize / 2;
    final textSpan = TextSpan(
      text: point.label,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontFamily: GoogleFonts.russoOne().fontFamily,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      // right from the badge
      Offset(point.x + badgePainter.width / 2.5,
          point.y - badgePainter.height / 2 - textPainter.height / 3 * 2),
    );
  }

  void drawWCPoint(Canvas canvas, Size size, Point point) {
    final badgeSize = __badgeSize(canvas);

    final color = point.color != null && point.color != 'none'
        ? HexColor.fromHex(point.color!) ?? Colors.white
        : Colors.white;

    final wcTextPainter = TextPainter(
      text: TextSpan(
        text: 'WC',
        style: TextStyle(
          color: color,
          fontSize: (badgeSize / 2).clamp(25, 33),
          fontFamily: GoogleFonts.russoOne().fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    wcTextPainter.layout();
    wcTextPainter.paint(
      canvas,
      // center at the point
      Offset(point.x - wcTextPainter.width / 2,
          point.y - wcTextPainter.height / 2),
    );
  }

  void drawStairsPoint(Canvas canvas, Size size, Point point) {}

  @override
  void draw(Canvas canvas, Size size) {
    if (painter == null || controller == null) return;

    final scale = _zc.scale;
    final isScaleSmall = scale < 0.2;

    for (final point in points) {
      if (point.label == null && point.kind != 'route_point') continue;
      if (!painter!.isPointInViewport(point, 10)) continue;

      if (point.kind == 'flat' || point.kind == null) {
        if (isScaleSmall) continue;
        drawFlatPoint(canvas, size, point);
      } else if (point.kind == 'point') {
        drawPinPoint(canvas, size, point);
      } else if (point.kind == 'wc') {
        if (isScaleSmall) continue;
        drawWCPoint(canvas, size, point);
      } else if (point.kind == 'stairs') {
        if (isScaleSmall) continue;
        drawStairsPoint(canvas, size, point);
      } else if (point.kind == 'route_point') {
        drawRoutePoint(canvas, size, point);
      }
    }
  }
}
