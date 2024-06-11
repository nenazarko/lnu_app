import 'package:flutter/foundation.dart';
import 'package:lnu_nav_app/components/map/controllers/map.dart';
import 'package:lnu_nav_app/helpers/data_manager/graph.dart';
import 'package:lnu_nav_app/types/point.dart';

import '../types/structures.dart';

class StructureData extends ChangeNotifier {
  Structure _structure = Structure.blank;
  MapController? _primaryController;

  MapController? get primaryController => _primaryController;
  Structure get structure => _structure;
  set structure(Structure structure) {
    _structure = structure;
    _primaryController = MapController(structData: this);
    notifyListeners();
  }

  Graph get graph => Graph(_structure.points, _structure.adjacencyList, _structure.offsets);
}
