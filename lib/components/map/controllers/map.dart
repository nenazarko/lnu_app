import 'package:flutter/material.dart';
import 'package:lnu_nav_app/components/map/controllers/zoom.dart';
import 'package:lnu_nav_app/store/structure-data.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'package:lnu_nav_app/types/structures.dart';
import 'package:provider/provider.dart';

class MapController extends ChangeNotifier {
  late Building _currentBuilding;
  late Floor _currentFloor;
  late StructureData _structData;
  late ZoomController zoomController;

  Building get currentBuilding => _currentBuilding;
  Floor get currentFloor => _currentFloor;

  MapController.fromContext({required BuildContext context, Building? building, Floor? floor, String? buildingId = '', String? floorId = '', ZoomController? zoomController})
    : this(
      zoomController: zoomController,
      structData: Provider.of<StructureData>(context, listen: false),
      building: building,
      floor: floor,
      buildingId: buildingId,
      floorId: floorId
  );


  MapController({required StructureData structData, Building? building, Floor? floor, String? buildingId = '', String? floorId = '', ZoomController? zoomController}) {
    _structData = structData;
    this.zoomController = zoomController ?? ZoomController();

    // try to get current building
    Building? curBuilding = defaultBuilding;
    if (building != null) {
      curBuilding = building;
    } else if (buildingId != null && buildingId.isNotEmpty) {
      curBuilding = getBuildingById(buildingId);
    }

    if (curBuilding != null) {
      _currentBuilding = curBuilding;
    } else {
      throw ArgumentError('[MapController] Building not found');
    }

    // try to get current floor
    Floor? curFloor = defaultFloor;
    if (floor != null) {
      curFloor = floor;
    } else if (floorId != null && floorId.isNotEmpty) {
      curFloor = getFloorById(_currentBuilding.id, floorId);
    }

    if (curFloor != null) {
      _currentFloor = curFloor;
    } else {
      throw ArgumentError('[MapController] Floor not found');
    }
  }

  // setters
  bool updateCurrentBuilding({String? buildingId, Building? building}) {
    if (building != null) {
      _currentBuilding = building;
      return true;
    } else if (buildingId != null && buildingId.isNotEmpty) {
      final newBuilding = getBuildingById(buildingId);
      if (newBuilding != null) {
        _currentBuilding = newBuilding;
        return true;
      }
    }
    return false;
  }

  bool updateCurrentFloor({String? floorId, Floor? floor}) {
    if (floor != null) {
      _currentFloor = floor;
      return true;
    } else if (floorId != null && floorId.isNotEmpty) {
      final newFloor = getFloorById(_currentBuilding.id, floorId);
      if (newFloor != null) {
        _currentFloor = newFloor;
        return true;
      }
    }
    return false;
  }

  // getters
  Building? getBuildingById(String id) {
    return _structData.structure.buildings[id];
  }

  Floor? getFloorById(String buildingId, String floorId) {
    return getBuildingById(buildingId)?.floors[floorId];
  }

  // points
  List<Point> get labeledPoints {
    return _structData.structure.points.values.where((point) => point.label != null).toList();
  }
  List<Point> get currentFloorPoints => getFloorPoints(_currentBuilding.id, _currentFloor.id, true);

  List<Point> getFloorPoints(String buildingId, String floorId, bool? labeledOnly) {
    return _structData.structure.points.values.where((point) {
      return point.buildingId == buildingId &&
          point.floorId == floorId &&
          (labeledOnly != true || point.label != null);
    }).toList();
  }


  // defaults
  Building? get defaultBuilding => getBuildingById(_structData.structure.defaultBuildingId);

  Floor? get defaultFloor => defaultBuilding != null
      ? getFloorById(defaultBuilding!.id, defaultBuilding!.defaultFloorId)
      : null;

  void commit() => notifyListeners();
}