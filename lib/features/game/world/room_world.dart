import 'package:flame/components.dart';

import '../../../core/config/game_config.dart';
import '../../cat/models/cat_activity.dart';
import '../../room/models/iso_grid.dart';
import '../components/cat_component.dart';
import '../components/room_floor_component.dart';
import '../components/room_tap_layer.dart';

/// The Flame world: room floor, tap handling and the cat.
///
/// Reports cat status changes outward via [onCatStatusChanged]; it knows
/// nothing about Flutter widgets or persistence.
class RoomWorld extends World {
  RoomWorld({required this.onCatStatusChanged});

  final CatStatusCallback onCatStatusChanged;

  final IsoGrid grid = IsoGrid.centered(
    columns: GameConfig.roomColumns,
    rows: GameConfig.roomRows,
    tileWidth: GameConfig.tileWidth,
    tileHeight: GameConfig.tileHeight,
    extraTopHeight: GameConfig.wallHeight,
  );

  CatComponent? _cat;
  RoomFloorComponent? _floor;

  @override
  Future<void> onLoad() async {
    final floor = RoomFloorComponent(grid: grid);
    final cat = CatComponent(
      grid: grid,
      startCell: const GridPoint(
        GameConfig.catStartColumn,
        GameConfig.catStartRow,
      ),
      onStatusChanged: _handleCatStatus,
    );
    _floor = floor;
    _cat = cat;

    addAll([
      floor,
      RoomTapLayer(grid: grid, onTileTapped: _handleTileTapped),
      cat,
    ]);
  }

  // --- Commands (called from Flutter via GameController) ---

  void sendCatToRandomTile() => _cat?.walkToRandomCell();

  // --- Internals ---

  void _handleTileTapped(GridPoint tile) {
    _floor?.targetTile = tile;
    _cat?.walkTo(tile);
  }

  void _handleCatStatus(CatActivity activity, GridPoint cell) {
    if (activity == CatActivity.idle) _floor?.targetTile = null;
    onCatStatusChanged(activity, cell);
  }
}
