import 'package:flutter/foundation.dart';

import '../../core/config/game_config.dart';
import '../cat/models/cat_activity.dart';
import '../room/models/iso_grid.dart';
import 'world/room_world.dart';

/// Bridge between Flutter UI and the Flame world.
///
/// - Flame -> Flutter: the world calls [updateCatStatus]; widgets listen.
/// - Flutter -> Flame: widgets call commands such as [sendCatToRandomTile].
class GameController extends ChangeNotifier {
  RoomWorld? _room;
  bool _disposed = false;

  CatActivity _catActivity = CatActivity.idle;
  GridPoint _catCell = const GridPoint(
    GameConfig.catStartColumn,
    GameConfig.catStartRow,
  );

  CatActivity get catActivity => _catActivity;
  GridPoint get catCell => _catCell;

  void attachRoom(RoomWorld room) => _room = room;

  /// Called by the Flame world when the cat's activity or tile changes.
  void updateCatStatus(CatActivity activity, GridPoint cell) {
    if (_disposed) return;
    if (activity == _catActivity && cell == _catCell) return;
    _catActivity = activity;
    _catCell = cell;
    notifyListeners();
  }

  /// Flutter -> Flame command: send the cat to a random tile.
  void sendCatToRandomTile() => _room?.sendCatToRandomTile();

  @override
  void dispose() {
    _disposed = true;
    _room = null;
    super.dispose();
  }
}
