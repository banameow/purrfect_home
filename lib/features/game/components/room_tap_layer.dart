import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../../core/config/game_config.dart';
import '../../room/models/iso_grid.dart';

/// Invisible layer covering the whole viewport that turns taps into
/// grid-tile taps (screen -> grid conversion happens in [IsoGrid]).
class RoomTapLayer extends PositionComponent with TapCallbacks {
  RoomTapLayer({required this.grid, required this.onTileTapped})
      : super(
          position: Vector2(
            -GameConfig.viewportWidth / 2,
            -GameConfig.viewportHeight / 2,
          ),
          size: Vector2(GameConfig.viewportWidth, GameConfig.viewportHeight),
          priority: -1,
        );

  final IsoGrid grid;
  final void Function(GridPoint tile) onTileTapped;

  @override
  void onTapDown(TapDownEvent event) {
    // localPosition is relative to this layer; add our top-left to get
    // world coordinates.
    final world = event.localPosition + position;
    final tile = grid.worldToGrid(Offset(world.x, world.y));
    if (tile != null) onTileTapped(tile);
  }
}
