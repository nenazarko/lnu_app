import 'package:lnu_nav_app/helpers/json-reader.dart';

typedef PointsMap = Map<String, Point>;

class Point implements JsonInterface<Point> {
  final String id;
  final String? label;

  final double x;
  final double y;
  final double z;

  final String buildingId;
  final String floorId;

  final String? kind;
  final String? color;

  const Point(this.id, this.x, this.y, this.z, this.buildingId, this.floorId,
      [this.label, this.kind, this.color]);

  static const zero = Point('P/0', 0, 0, 0, 'bid', 'fid');

  Point clone() => Point(id, x, y, z, buildingId, floorId, label, kind, color);

  @override
  fromJson(Map<String, dynamic> json) {
    try {
      final id = json['pointId'];
      final x = json['x'].toDouble();
      final y = json['y'].toDouble();
      final z = (json['z'] ?? 1).toDouble();
      final label = json['label'];
      final buildingId = json['buildingId'];
      final floorId = json['floorId'];
      final kind = json['kind'] ?? (label != null ? 'flat' : 'route-point');
      final color = json['color'];

      return Point(id, x, y, z, buildingId, floorId, label, kind, color);
    } catch (e, stacktrace) {
      print('Failed to parse Point | $e \n$stacktrace');
      throw Exception('Failed to parse Point | $e');
    }
  }

  @override
  String toString() => 'Point($id, (${x.toInt()}, ${y.toInt()}, ${z.toInt()}), $label, $kind, $buildingId)';

  // equals
  static bool idEq(String a, String b) => a == b;
}
