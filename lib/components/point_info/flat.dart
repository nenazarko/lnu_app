import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lnu_nav_app/components/point_info/base.dart';

class PointInfoSheetFlat extends PointInfoSheet {
  PointInfoSheetFlat(super.point);

  @override
  List<Widget> header() {
    return [
      Center(
        child: Text(
          "Аудиторія №${point.label}",
          style: GoogleFonts.russoOne(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ];
  }
}