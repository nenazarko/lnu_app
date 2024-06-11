import 'package:lnu_nav_app/types/pair.dart';

import 'point.dart';

typedef AdjacencyList = Map<Point, List<Pair<Point, double>>>;

buildAdjacencyList(PointsMap points, Map<String, dynamic> nodes) {
  AdjacencyList adjacencyList = {};

  for (final rawNode in nodes.entries) {
    final keyPoint = points[rawNode.key];
    if (keyPoint == null) {
      throw Exception('Failed to find point with id: ${rawNode.key}');
    }

    List<Pair<Point, double>> valuePoints = [];

    for (final e in rawNode.value.entries) {
      final point = points[e.key];
      double weight = e.value.toDouble();
      if (point == null) {
        throw Exception('Failed to find point with id: ${e.key}');
      }
      valuePoints.add(Pair(point, weight));

      adjacencyList[keyPoint] = valuePoints;
    }
  }

  return adjacencyList;
}
