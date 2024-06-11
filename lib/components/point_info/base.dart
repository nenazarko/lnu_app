import 'package:flutter/material.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/variables.dart';

import 'flat.dart';
import 'point.dart';

abstract class PointInfoSheet {
  final Point point;
  PointInfoSheet(this.point);

  List<Widget> header();
  Widget body() => Container();

  static PointInfoSheet? __getSheetFromPoint(Point point) {
    switch (point.kind) {
      case 'point':
        return PointInfoSheetPoint(point);
      case 'flat':
        return PointInfoSheetFlat(point);
      default:
        return null;
    }
  }

  static void generate(BuildContext context, Point point) {
    final sheet = __getSheetFromPoint(point);
    if (sheet == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: sheet.header(),
              ),
            ),
            Divider(color: Colors.white.withOpacity(0.5)),

            // button to create route
            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purpleColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                // icon + text
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // icons with target route
                    Icon(Icons.directions, color: Colors.white),
                    SizedBox(width: 10),
                    Text("Прокласти маршрут", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            sheet.body()
          ],
        );
      },
    );
  }
}