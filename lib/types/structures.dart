import 'package:lnu_nav_app/helpers/json-reader.dart';
import 'package:lnu_nav_app/types/point.dart';
import 'adjacency_list.dart';

class BuildingOffset implements JsonInterface<BuildingOffset> {
  final double x;
  final double y;

  const BuildingOffset({
    required this.x,
    required this.y,
  });

  static const BuildingOffset zero = BuildingOffset(x: 0, y: 0);

  @override
  toString() {
    return "($x, $y)";
  }

  @override
  fromJson(Map<String, dynamic> json) {
    return BuildingOffset(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }
}

class Floor implements JsonInterface<Floor> {
  final String id;
  final String name;
  final double z;
  final String? subtitle;
  final String background;

  const Floor({
    required this.id,
    required this.name,
    required this.z,
    required this.background,
    this.subtitle,
  });

  static const blank = Floor(
    id: '0',
    name: 'Unknown',
    z: 0,
    background: '',
  );

  @override
  String toString() => '$name ($subtitle) (Z:$z) (#$id) | $background';

  @override
  fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      name: json['name'],
      z: (json['z'] ?? 1).toDouble(),
      background: json['background'],
      subtitle: json['subtitle'],
    );
  }
}

class Building implements JsonInterface<Building> {
  final String id;
  final String name;
  final Map<String, Floor> floors;
  final String? subtitle;
  final String defaultFloorId;
  final BuildingOffset offset;

  const Building({
    required this.id,
    required this.name,
    required this.floors,
    required this.defaultFloorId,
    this.subtitle,
    this.offset = BuildingOffset.zero,
  });

  static const blank = Building(
    id: '0',
    name: 'Unknown',
    defaultFloorId: '0',
    floors: {},
    offset: BuildingOffset.zero,
  );

  @override
  String toString() => '$name | ${floors.length} floors';

  @override
  fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'],
      name: json['name'],
      defaultFloorId: json['defaultFloor'],
      subtitle: json['subtitle'],
      offset: json['offset'] != null
          ? BuildingOffset.zero.fromJson(json['offset'])
          : BuildingOffset.zero,
      floors: (json['floors'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Floor.blank.fromJson(value))),
    );
  }
}

class CompactBuilding implements JsonInterface<CompactBuilding> {
  final String id;
  final String name;
  final int floors;
  final String? subtitle;
  final String defaultFloorId;

  const CompactBuilding({
    required this.id,
    required this.name,
    required this.floors,
    required this.defaultFloorId,
    this.subtitle,
  });

  static const blank = CompactBuilding(
    id: '0',
    name: 'Unknown',
    defaultFloorId: '0',
    floors: 0,
  );

  @override
  String toString() => '$name | $floors floors';

  @override
  fromJson(Map<String, dynamic> json) {
    return CompactBuilding(
      id: json['id'],
      name: json['name'],
      defaultFloorId: json['defaultFloor'],
      subtitle: json['subtitle'],
      floors: (json['floors'] as Map<String, dynamic>).length
    );
  }
}

class GeoLocation implements JsonInterface<GeoLocation> {
  final double lat;
  final double lon;

  const GeoLocation({
    required this.lat,
    required this.lon,
  });

  static const GeoLocation zero = GeoLocation(lat: 0, lon: 0);

  @override
  fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}

class StructureLocation implements JsonInterface<StructureLocation> {
  final String country;
  final String city;

  final String address;
  final String? address2;

  final GeoLocation? geoLocation;

  const StructureLocation({
    required this.address,
    this.address2,
    this.geoLocation,
    this.country = 'Україна',
    this.city = 'м. Львів',
  });

  static const StructureLocation empty = StructureLocation(
    address: 'Unknown',
  );

  @override toString() => [
        address,
        if (address2 != null) address2,
        city,
        country,
      ].join(', ');

  @override
  fromJson(Map<String, dynamic> json) {
    return StructureLocation(
      address: json['address'],
      address2: json['address2'],
      geoLocation: json['geoLocation'] != null
          ? GeoLocation.zero.fromJson(json['geoLocation'])
          : null,
      country: json['country'],
      city: json['city'],
    );
  }
}

class Structure implements JsonInterface<Structure> {
  final String id;
  final String name;
  final StructureLocation location;
  final Map<String, Building> buildings;
  final String defaultBuildingId;
  final String? subtitle;
  final Map<String, Point> points;
  final AdjacencyList adjacencyList;

  const Structure({
    required this.id,
    required this.name,
    required this.buildings,
    required this.defaultBuildingId,
    required this.location,
    required this.points,
    required this.adjacencyList,
    this.subtitle,
  });

  get offsets => buildings.map((key, value) => MapEntry(key, value.offset));

  @override
  fromJson(Map<String, dynamic> json) {
    final points = (json['points'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, Point.zero.fromJson(value)));

    final nodes = json['nodes'];
    final adjacencyList = buildAdjacencyList(points, nodes);

    return Structure(
      id: json['id'],
      name: json['name'],
      defaultBuildingId: json['defaultBuilding'],
      subtitle: json['subtitle'],
      points: points,
      adjacencyList: adjacencyList,
      location: StructureLocation.empty.fromJson(json['location']),
      buildings: (json['buildings'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Building.blank.fromJson(value))),
    );
  }

  static const blank = Structure(
    id: '0',
    name: 'Unknown',
    defaultBuildingId: '0',
    location: StructureLocation.empty,
    buildings: {},
    points: {},
    adjacencyList: {},
  );
}

class CompactStructure implements JsonInterface<CompactStructure> {
  final String id;
  final String name;
  final StructureLocation location;
  final Map<String, CompactBuilding> buildings;
  final String defaultBuildingId;
  final String? subtitle;

  const CompactStructure({
    required this.id,
    required this.name,
    required this.buildings,
    required this.defaultBuildingId,
    required this.location,
    this.subtitle,
  });

  @override
  fromJson(Map<String, dynamic> json) {
    return CompactStructure(
      id: json['id'],
      name: json['name'],
      defaultBuildingId: json['defaultBuilding'],
      subtitle: json['subtitle'],
      location: StructureLocation.empty.fromJson(json['location']),
      buildings: (json['buildings'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, CompactBuilding.blank.fromJson(value))),
    );
  }

  static const blank = CompactStructure(
    id: '0',
    name: 'Unknown',
    defaultBuildingId: '0',
    location: StructureLocation.empty,
    buildings: {},
  );
}
