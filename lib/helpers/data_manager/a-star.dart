import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:lnu_nav_app/helpers/data_manager/graph.dart';
import 'package:lnu_nav_app/helpers/simplify-string.dart';
import 'package:lnu_nav_app/types/pair.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/types/structures.dart';

class AStar {
  final Graph graph;
  AStar(this.graph);

  math.Point _coordinatesWithOffset(Point point) {
    final offset = graph.offsets[point.buildingId]
        ?? BuildingOffset.zero;
    return math.Point(
      point.x,
      point.y
    );

    return math.Point(
      point.x + offset.x,
      point.y + offset.y,
    );
  }

  // This is a heuristic function which is having equal values for all nodes
  double euclideanHeuristic(Point p1, Point p2) {
    final ep1 = _coordinatesWithOffset(p1);
    final ep2 = _coordinatesWithOffset(p2);
    return math.sqrt(
            math.pow(ep1.x - ep2.x, 2) +
            math.pow(ep1.y - ep2.y, 2)
    );
  }


  double distance(List<Point> path) {
    double distance = 0;
    // if (distance <= 0) return 0;
    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];
      distance += euclideanHeuristic(current, next);
    }
    return distance;
  }

  List<Pair<Point, double>> findClosestPoints(Point start,
      {int amount = 5, String? search}) {
    // a* to all points, calculate distance, sort by distance, return first {amount}
    final labeledPoints = graph.labeledPoints;

    final points = simplifyString(search).isEmpty
        ? labeledPoints
        : labeledPoints
            .where((element) =>
                simplifyString(element.label!).contains(simplifyString(search)))
            .toList();

    final distances = <Point, double>{};
    for (final point in points) {
      try {
        final path = findPath(start, point);
        if (path != null) {
          distances[point] = distance(path);
        }
      } catch (e, stacktrace) {
        if (kDebugMode) {
          print('Failed to find path to $point} from $start | $e\n$stacktrace');
        }
      }
    }

    final sorted = distances.entries
        .where((element) => element.value > 0.0)
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    return sorted.map((e) => Pair(e.key, e.value)).take(amount).toList();
  }

  List<Point>? findPath(Point start, Point stop) {
    int iterations = 0;
    Set<String> openLst = {start.id};
    Set<String> closedLst = {};
    Map<Point, double> poo = {start: 0.0};
    Map<Point, Point> parent = {start: start};

    // print('Start: $start || Stop: $stop');

    while (openLst.isNotEmpty) {
      Point? currentNode;
      iterations++;

      for (final pointId in openLst) {
        final point = graph.getPoint(pointId);
        if (point == null) {
          print('[A*][1] Point is null');
          return null;
        }

        if (currentNode == null ||
            poo[point]! + euclideanHeuristic(point, stop) <
                poo[currentNode]! + euclideanHeuristic(currentNode, stop)) {
          currentNode = point;
        }
      }

      if (currentNode == null) {
        print('[A*][4] Current node is null');
        return null;
      }

      if (currentNode.id == stop.id) {
        final path = <Point>[];

        while (parent[currentNode]?.id != currentNode?.id) {
          path.add(currentNode!);
          currentNode = parent[currentNode];
        }

        path.add(start);
        return path.reversed.toList();
      }


      for (final neighbor in graph.getNeighbors(currentNode)) {
        final neighbourPoint = neighbor.first;
        final weight = neighbor.second;

        final isOpen = openLst.contains(neighbourPoint.id);
        final isClosed = closedLst.contains(neighbourPoint.id);

        if (!isOpen && !isClosed) {
          openLst.add(neighbourPoint.id);
          poo[neighbourPoint] = poo[currentNode]! + weight;
          parent[neighbourPoint] = currentNode;
        } else if (poo[neighbourPoint]! > poo[currentNode]! + weight) {
          poo[neighbourPoint] = poo[currentNode]! + weight;
          parent[neighbourPoint] = currentNode;

          if (closedLst.contains(neighbourPoint.id)) {
            openLst.add(neighbourPoint.id);
            closedLst.remove(neighbourPoint.id);
          }
        }
      }


      openLst.remove(currentNode.id);
      closedLst.add(currentNode.id);
    }

    print('Path does not exist! / iterations: $iterations');
    print('Target: $stop');
    return null;
  }
}
