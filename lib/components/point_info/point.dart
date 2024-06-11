import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lnu_nav_app/components/point_info/base.dart';
import 'package:lnu_nav_app/extensions/hex_color.dart';


class PointInfoSheetPoint extends PointInfoSheet {
  PointInfoSheetPoint(super.point);

  @override
  List<Widget> header() {
    return [
      Icon(
          Icons.location_on,
          color: point.color != null
              ? HexColor.fromHex(point.color!) ?? Colors.white
              : Colors.white
      ),
      const SizedBox(width: 10),
      Text(
        point.label!,
        style: GoogleFonts.russoOne(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    ];
  }
}