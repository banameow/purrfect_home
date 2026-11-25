import 'package:flutter/material.dart';

import '../services/economy_service.dart';

/// Shows how many coins are waiting in the jar and collects them on tap.
/// Disabled while the jar is empty.
class CollectButton extends StatelessWidget {
  const CollectButton({
    super.key,
    required this.economyService,
    required this.onCollect,
  });

  final EconomyService economyService;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: economyService,
      builder: (context, _) {
        final pending = economyService.pendingCoins;
        final full = economyService.isPendingFull;
        return FilledButton.tonalIcon(
          onPressed: pending > 0 ? onCollect : null,
          icon: const Icon(Icons.savings),
          label: Text(full ? 'Collect $pending (jar full)' : 'Collect $pending'),
        );
      },
    );
  }
}
