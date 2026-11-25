import 'package:flutter/material.dart';

import '../services/economy_service.dart';

/// Shows the wallet balance.
class CoinBadge extends StatelessWidget {
  const CoinBadge({super.key, required this.economyService});

  final EconomyService economyService;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: economyService,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xE6FFFFFF),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.monetization_on,
                size: 20,
                color: Color(0xFFF2B01E),
              ),
              const SizedBox(width: 6),
              Text(
                '${economyService.coins}',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
