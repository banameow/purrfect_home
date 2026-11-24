import 'package:flutter/material.dart';

import '../services/cat_service.dart';

/// Feed / Pet / Play buttons. Disabled while the cat is busy.
class InteractionBar extends StatelessWidget {
  const InteractionBar({
    super.key,
    required this.catService,
    required this.onInteract,
  });

  final CatService catService;
  final ValueChanged<CatInteraction> onInteract;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: catService,
      builder: (context, _) {
        final enabled = !catService.isBusy;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _button(Icons.restaurant, 'Feed', CatInteraction.feed, enabled),
            _button(Icons.favorite, 'Pet', CatInteraction.pet, enabled),
            _button(Icons.toys, 'Play', CatInteraction.play, enabled),
          ],
        );
      },
    );
  }

  Widget _button(
    IconData icon,
    String label,
    CatInteraction type,
    bool enabled,
  ) {
    return FilledButton.icon(
      onPressed: enabled ? () => onInteract(type) : null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}