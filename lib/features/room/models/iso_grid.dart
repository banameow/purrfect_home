import 'dart:ui';

/// A tile position in the room grid. (0,0) is the tile at the top corner.
class GridPoint {
  const GridPoint(this.col, this.row);

  final int col;
  final int row;

  @override
  bool operator ==(Object other) =>
      other is GridPoint && other.col == col && other.row == row;

  @override
  int get hashCode => Object.hash(col, row);

  @override
  String toString() => 'GridPoint($col, $row)';
}

/// Pure-Dart isometric grid math (no Flame dependency, easy to unit test).
///
/// Grid axes: `col` runs down-right, `row` runs down-left.
/// World coordinates are the same space Flame components use.
class IsoGrid {
  const IsoGrid({
    required this.columns,
    required this.rows,
    required this.tileWidth,
    required this.tileHeight,
    this.origin = Offset.zero,
  });

  /// Creates a grid whose floor (plus [extraTopHeight] of walls above it)
  /// is vertically centered around world (0, 0).
  factory IsoGrid.centered({
    required int columns,
    required int rows,
    required double tileWidth,
    required double tileHeight,
    double extraTopHeight = 0,
  }) {
    return IsoGrid(
      columns: columns,
      rows: rows,
      tileWidth: tileWidth,
      tileHeight: tileHeight,
      origin: Offset(0, -(columns + rows) * tileHeight / 4 + extraTopHeight / 2),
    );
  }

  final int columns;
  final int rows;
  final double tileWidth;
  final double tileHeight;

  /// World position of the top corner of tile (0, 0).
  final Offset origin;

  bool contains(GridPoint p) =>
      p.col >= 0 && p.col < columns && p.row >= 0 && p.row < rows;

  /// Grid -> world: the center of the given tile.
  Offset gridToWorld(GridPoint p) {
    return Offset(
      origin.dx + (p.col - p.row) * tileWidth / 2,
      origin.dy + (p.col + p.row + 1) * tileHeight / 2,
    );
  }

  /// World -> grid: the tile under [world], or null if outside the room.
  GridPoint? worldToGrid(Offset world) {
    final dx = (world.dx - origin.dx) / tileWidth;
    final dy = (world.dy - origin.dy) / tileHeight;
    final p = GridPoint((dy + dx).floor(), (dy - dx).floor());
    return contains(p) ? p : null;
  }

  /// The four corners of a tile: top, right, bottom, left.
  List<Offset> tileCorners(GridPoint p) {
    final c = gridToWorld(p);
    final hw = tileWidth / 2;
    final hh = tileHeight / 2;
    return [
      Offset(c.dx, c.dy - hh),
      Offset(c.dx + hw, c.dy),
      Offset(c.dx, c.dy + hh),
      Offset(c.dx - hw, c.dy),
    ];
  }

  // Corners of the whole floor diamond.
  Offset get topCorner => origin;
  Offset get rightCorner =>
      origin + Offset(columns * tileWidth / 2, columns * tileHeight / 2);
  Offset get leftCorner =>
      origin + Offset(-rows * tileWidth / 2, rows * tileHeight / 2);
  Offset get bottomCorner => origin +
      Offset((columns - rows) * tileWidth / 2, (columns + rows) * tileHeight / 2);
}
