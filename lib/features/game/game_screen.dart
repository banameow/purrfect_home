import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/config/game_config.dart';
import '../cat/services/cat_service.dart';
import '../cat/widgets/cat_status_panel.dart';
import '../cat/widgets/interaction_bar.dart';
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
  late final CatService _catService;
  late final GameController _controller;
  late final HomeGame _game;

  @override
  void initState() {
    super.initState();
    _catService = CatService();
    _controller = GameController(catService: _catService);
    final room = RoomWorld(
      catService: _catService,
      onCatStatusChanged: _controller.updateCatStatus,
    );
    _controller.attachRoom(room);
    _game = HomeGame(room: room);
  }

  @override
  void dispose() {
    _controller.dispose();
    _catService.dispose();
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
                  _ActivityChip(controller: _controller),
                  const SizedBox(height: 8),
                  CatStatusPanel(catService: _catService),
                  const Spacer(),
                  _FeedbackText(controller: _controller),
                  const SizedBox(height: 8),
                  InteractionBar(
                    catService: _catService,
                    onInteract: _controller.interact,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pets, size: 18),
              const SizedBox(width: 8),
              Text(
                '${GameConfig.catName} · ${controller.catActivity.label}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FeedbackText extends StatelessWidget {
  const _FeedbackText({required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        // Fixed height so the layout does not jump when the text appears.
        return SizedBox(
          height: 24,
          child: Center(
            child: Text(
              controller.feedbackMessage ?? '',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
      },
    );
  }
}