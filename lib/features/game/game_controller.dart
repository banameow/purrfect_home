import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/config/game_config.dart';
import '../cat/models/cat_activity.dart';
import '../cat/services/cat_service.dart';
import '../room/models/iso_grid.dart';
import 'world/room_world.dart';

/// Bridge between Flutter UI and the Flame world.
///
/// - Flame -> Flutter: the world calls [updateCatStatus]; widgets listen.
/// - Flutter -> Flame: widgets call [interact]; accepted interactions are
///   forwarded to the world so the cat animates them.
class GameController extends ChangeNotifier {
  GameController({required this.catService});

  final CatService catService;

  RoomWorld? _room;
  bool _disposed = false;
  Timer? _feedbackTimer;

  CatActivity _catActivity = CatActivity.idle;
  GridPoint _catCell = const GridPoint(
    GameConfig.catStartColumn,
    GameConfig.catStartRow,
  );
  String? _feedbackMessage;

  CatActivity get catActivity => _catActivity;
  GridPoint get catCell => _catCell;
  String? get feedbackMessage => _feedbackMessage;

  void attachRoom(RoomWorld room) => _room = room;

  /// Called by the Flame world when the cat's activity or tile changes.
  void updateCatStatus(CatActivity activity, GridPoint cell) {
    if (_disposed) return;
    if (activity == _catActivity && cell == _catCell) return;
    _catActivity = activity;
    _catCell = cell;
    notifyListeners();
  }

  /// Feed / pet / play. Status changes are applied by [CatService]; the
  /// animation is played by the world only if the interaction was accepted.
  void interact(CatInteraction type) {
    final result = catService.interact(type);
    if (result.accepted) {
      _room?.playInteraction(type, result.durationSeconds);
    }
    _showFeedback(result.message);
  }

  void _showFeedback(String message) {
    if (_disposed) return;
    _feedbackTimer?.cancel();
    _feedbackMessage = message;
    notifyListeners();
    _feedbackTimer = Timer(
      Duration(milliseconds: (GameConfig.feedbackSeconds * 1000).round()),
      () {
        if (_disposed) return;
        _feedbackMessage = null;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    _feedbackTimer?.cancel();
    _room = null;
    super.dispose();
  }
}