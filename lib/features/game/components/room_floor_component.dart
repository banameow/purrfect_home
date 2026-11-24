import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/config/game_config.dart';
import '../../../core/constants/game_constants.dart';
import '../../room/models/iso_grid.dart';

/// Draws the isometric floor, the two back walls and the floor's edge.
///
/// Pure rendering: it holds no gameplay logic.
class RoomFloorComponent extends PositionComponent {
  RoomFloorComponent({required this.grid});

  final IsoGrid grid;

  /// Optional highlighted tile (e.g. where the player tapped).
  GridPoint? targetTile;

  final List<({Path path, bool isLight})> _tiles = [];

  final Paint _lightTile = Paint()..color = GameColors.floorLight;
  final Paint _darkTile = Paint()..color = GameColors.floorDark;
  final Paint _outline = Paint()
    ..color = GameColors.floorOutline
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1;
  final Paint _leftWall = Paint()..color = GameColors.wallLeft;
  final Paint _rightWall = Paint()..color = GameColors.wallRight;
  final Paint _edge = Paint()..color = GameColors.floorEdge;
  final Paint _marker = Paint()..color = GameColors.tileMarker;

  @override
  Future<void> onLoad() async {
    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.columns; col++) {
        _tiles.add((
          path: _pathFor(GridPoint(col, row)),
          isLight: (col + row).isEven,
        ));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    _drawWalls(canvas);
    _drawFloorEdge(canvas);

    for (final tile in _tiles) {
      canvas.drawPath(tile.path, tile.isLight ? _lightTile : _darkTile);
      canvas.drawPath(tile.path, _outline);
    }

    final target = targetTile;
    if (target != null && grid.contains(target)) {
      canvas.drawPath(_pathFor(target), _marker);
    }
  }

  void _drawWalls(Canvas canvas) {
    const up = Offset(0, -GameConfig.wallHeight);
    canvas.drawPath(
      _quad(grid.topCorner, grid.leftCorner, grid.leftCorner + up,
          grid.topCorner + up),
      _leftWall,
    );
    canvas.drawPath(
      _quad(grid.topCorner, grid.rightCorner, grid.rightCorner + up,
          grid.topCorner + up),
      _rightWall,
    );
  }

  void _drawFloorEdge(Canvas canvas) {
    const down = Offset(0, GameConfig.floorEdgeThickness);
    canvas.drawPath(
      _quad(grid.leftCorner, grid.bottomCorner, grid.bottomCorner + down,
          grid.leftCorner + down),
      _edge,
    );
    canvas.drawPath(
      _quad(grid.bottomCorner, grid.rightCorner, grid.rightCorner + down,
          grid.bottomCorner + down),
      _edge,
    );
  }

  Path _pathFor(GridPoint p) {
    final c = grid.tileCorners(p);
    return _quad(c[0], c[1], c[2], c[3]);
  }

  Path _quad(Offset a, Offset b, Offset c, Offset d) {
    return Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
  }
}
