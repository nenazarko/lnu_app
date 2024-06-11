import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/types/structures.dart';

import '../../types/pair.dart';

class Graph {
  final Map<Point, List<Pair<Point, double>>> adjacticityList;
  final Map<String, Point> points;
  final Map<String, BuildingOffset> offsets;
  late List<Point> labeledPoints;

  static blank() => Graph({}, {}, {});

  Graph(this.points, this.adjacticityList, this.offsets) {
    labeledPoints =
        points.values.where((element) => element.label != null).toList();
  }

  List<Point> labeledPointsForFloor(String id) {
    return labeledPoints.where((element) => element.id == id).toList();
  }

  List<Pair<Point, double>> getNeighbors(Point point) =>
      adjacticityList[point]!;

  Point? getPoint(String id) => points[id];
}
