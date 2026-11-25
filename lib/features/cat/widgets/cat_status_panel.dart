import 'package:flutter/material.dart';

import '../../../core/config/game_config.dart';
import '../services/cat_service.dart';

/// Four status bars (Hunger, Energy, Happiness, Affection).
class CatStatusPanel extends StatelessWidget {
  const CatStatusPanel({super.key, required this.catService});

  final CatService catService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catService,
      builder: (context, _) {
        final s = catService.state;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatBar(
                      icon: Icons.restaurant,
                      label: 'Hunger',
                      value: s.hunger,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBar(
                      icon: Icons.bolt,
                      label: 'Energy',
                      value: s.energy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _StatBar(
                      icon: Icons.mood,
                      label: 'Happiness',
                      value: s.happiness,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatBar(
                      icon: Icons.favorite,
                      label: 'Affection',
                      value: s.affection,
                      lowIsBad: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({
    required this.icon,
    required this.label,
    required this.value,
    this.lowIsBad = true,
  });

  final IconData icon;
  final String label;
  final double value;
  final bool lowIsBad;

  @override
  Widget build(BuildContext context) {
    final low = lowIsBad && value < GameConfig.lowStatusThreshold;
    final color = !lowIsBad
        ? const Color(0xFFF06292)
        : (low ? const Color(0xFFE57373) : const Color(0xFF81C784));

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11)),
              const SizedBox(height: 2),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: value / GameConfig.statusMax,
                  minHeight: 8,
                  color: color,
                  backgroundColor: const Color(0x14000000),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}