import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/game.dart';

import '../../../core/config/game_config.dart';
import '../../../core/constants/game_constants.dart';
import 'room_world.dart';

/// The Flame game: a fixed-resolution camera looking at the [RoomWorld].
///
/// The camera keeps a fixed 400x700 view and scales/letterboxes it to the
/// device, so the room looks the same on every phone.
class HomeGame extends FlameGame {
  HomeGame({required RoomWorld room})
      : super(
          world: room,
          camera: CameraComponent.withFixedResolution(
            width: GameConfig.viewportWidth,
            height: GameConfig.viewportHeight,
          ),
        );

  @override
  Color backgroundColor() => GameColors.background;
}
