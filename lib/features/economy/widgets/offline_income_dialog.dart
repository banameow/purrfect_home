import 'package:flutter/material.dart';

import '../../../core/config/game_config.dart';
import '../models/offline_income_result.dart';

/// "Welcome back" dialog shown when offline income was earned.
/// The coins are already in the jar; [onCollect] moves them to the wallet.
class OfflineIncomeDialog extends StatelessWidget {
  const OfflineIncomeDialog({
    super.key,
    required this.result,
    required this.onCollect,
  });

  final OfflineIncomeResult result;
  final VoidCallback onCollect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('Welcome back!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${GameConfig.catName} kept the coins coming while you were away.'),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: Color(0xFFF2B01E),
              ),
              const SizedBox(width: 8),
              Text(
                '+${result.coins} ${result.coins == 1 ? 'coin' : 'coins'}',
                style: textTheme.titleLarge,
              ),
            ],
          ),
          if (result.wasCapped) ...[
            const SizedBox(height: 12),
            Text(
              'You were away for ${_format(result.awayDuration)}. '
              'Income counts for up to ${_format(result.creditedDuration)}.',
              style: textTheme.bodySmall,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Later'),
        ),
        FilledButton(
          onPressed: () {
            onCollect();
            Navigator.of(context).pop();
          },
          child: const Text('Collect'),
        ),
      ],
    );
  }

  static String _format(Duration d) {
    if (d.inMinutes < 1) return 'less than a minute';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
  }
}
