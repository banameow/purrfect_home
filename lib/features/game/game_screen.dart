import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/config/game_config.dart';
import 'game_controller.dart';
import 'world/home_game.dart';
import 'world/room_world.dart';

/// Home / Room screen: Flame game in the background, Flutter HUD on top.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController _controller;
  late final HomeGame _game;

  @override
  void initState() {
    super.initState();
    _controller = GameController();
    final room = RoomWorld(onCatStatusChanged: _controller.updateCatStatus);
    _controller.attachRoom(room);
    _game = HomeGame(room: room);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatusChip(controller: _controller),
                  const Spacer(),
                  _BottomPanel(controller: _controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final cell = controller.catCell;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pets, size: 20),
              const SizedBox(width: 8),
              Text(
                '${GameConfig.catName} · ${controller.catActivity.label}'
                ' · tile ${cell.col}, ${cell.row}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Tap the floor to call ${GameConfig.catName}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: controller.sendCatToRandomTile,
          icon: const Icon(Icons.shuffle),
          label: const Text('Send to random spot'),
        ),
      ],
    );
  }
}
