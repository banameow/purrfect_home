import 'package:flutter_test/flutter_test.dart';
// If your package is not called purrfect_home, change this import.
import 'package:purrfect_home/features/room/models/iso_grid.dart';

void main() {
  const grid = IsoGrid(
    columns: 6,
    rows: 6,
    tileWidth: 60,
    tileHeight: 30,
    origin: Offset(0, -90),
  );

  group('IsoGrid', () {
    test('contains accepts in-room tiles and rejects outside tiles', () {
      expect(grid.contains(const GridPoint(0, 0)), isTrue);
      expect(grid.contains(const GridPoint(5, 5)), isTrue);
      expect(grid.contains(const GridPoint(6, 0)), isFalse);
      expect(grid.contains(const GridPoint(0, 6)), isFalse);
      expect(grid.contains(const GridPoint(-1, 2)), isFalse);
    });

    test('grid -> world -> grid round-trips for every tile', () {
      for (var row = 0; row < grid.rows; row++) {
        for (var col = 0; col < grid.columns; col++) {
          final tile = GridPoint(col, row);
          expect(grid.worldToGrid(grid.gridToWorld(tile)), tile);
        }
      }
    });

    test('points near a tile center (inside the diamond) map to that tile', () {
      const tile = GridPoint(3, 2);
      final c = grid.gridToWorld(tile);
      for (final offset in const [
        Offset(12, 0),
        Offset(-12, 0),
        Offset(0, 6),
        Offset(0, -6),
      ]) {
        expect(grid.worldToGrid(c + offset), tile);
      }
    });

    test('points outside the room return null', () {
      expect(grid.worldToGrid(grid.origin + const Offset(0, -5)), isNull);
      expect(grid.worldToGrid(const Offset(1000, 1000)), isNull);
      expect(grid.worldToGrid(const Offset(-1000, 0)), isNull);
    });

    test('neighbouring tiles are half a tile apart in screen space', () {
      final a = grid.gridToWorld(const GridPoint(2, 2));
      final right = grid.gridToWorld(const GridPoint(3, 2));
      final left = grid.gridToWorld(const GridPoint(2, 3));
      expect(right - a, const Offset(30, 15));
      expect(left - a, const Offset(-30, 15));
    });

    test('floor corners match tile corners', () {
      expect(grid.tileCorners(const GridPoint(0, 0))[0], grid.topCorner);
      expect(grid.tileCorners(const GridPoint(5, 0))[1], grid.rightCorner);
      expect(grid.tileCorners(const GridPoint(0, 5))[3], grid.leftCorner);
      expect(grid.tileCorners(const GridPoint(5, 5))[2], grid.bottomCorner);
    });

    test('centered grid is vertically centered including walls', () {
      final centered = IsoGrid.centered(
        columns: 6,
        rows: 6,
        tileWidth: 60,
        tileHeight: 30,
        extraTopHeight: 100,
      );
      final top = centered.topCorner.dy - 100;
      final bottom = centered.bottomCorner.dy;
      expect(top, closeTo(-bottom, 0.001));
    });
  });
}
