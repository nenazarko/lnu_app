import 'package:flutter/foundation.dart';
import 'package:lnu_nav_app/helpers/data_manager/graph.dart';
import 'package:lnu_nav_app/types/adjacency_list.dart';
import 'package:lnu_nav_app/types/point.dart';

import '../types/structures.dart';

// class MapData extends ChangeNotifier {
//   Floor? currentFloor;
//   Building? currentBuilding;
//   Graph graph = Graph.blank();
//
//   MapData updateFloor(Floor newFloor) {
//     currentFloor = newFloor;
//     return this;
//   }
//
//   MapData updateGraph(PointsMap points, AdjacencyList adjacencyList) {
//     graph = Graph(points, adjacencyList);
//     return this;
//   }
//
//   Floor? prevFloor() {
//     var currentFloorIndex = floors.indexOf(currentFloor);
//
//     if (currentFloorIndex == floors.length - 1) {
//       return null;
//     } else {
//       currentFloorIndex++;
//     }
//
//     return floors[currentFloorIndex];
//   }
//
//   Floor? nextFloor() {
//     var currentFloorIndex = floors.indexOf(currentFloor);
//
//     if (currentFloorIndex == 0) {
//       return null;
//     } else {
//       currentFloorIndex--;
//     }
//     return floors[currentFloorIndex];
//   }
//
//   void commit() {
//     notifyListeners();
//   }
// }
