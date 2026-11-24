import 'dart:math';

import '../../../core/config/game_config.dart';
import '../../cat/models/cat_activity.dart';
import '../../cat/models/cat_state.dart';

class BehaviorChoice {
  const BehaviorChoice(this.activity, this.durationSeconds);

  final CatActivity activity;

  /// How long to stay in [activity]. 0 for walking (ends on arrival).
  final double durationSeconds;
}

/// Simple weighted-random behavior rules (no AI):
/// - Tired cat -> sleeps.
/// - Hungry/unhappy cat -> sits around more, does not start playing.
/// - Otherwise idle / walk / sit, and sometimes play if it has the energy.
/// - Never repeats the activity it just finished (except walking).
class CatBehaviorSystem {
  CatBehaviorSystem({Random? random}) : _random = random ?? Random();

  final Random _random;

  BehaviorChoice choose(CatState state, {required CatActivity previous}) {
    if (state.isTired) {
      return BehaviorChoice(CatActivity.sleeping, sleepDuration(state));
    }

    final weights = <CatActivity, double>{
      CatActivity.idle: 3,
      CatActivity.walking: 4,
      CatActivity.sitting: 3,
    };

    if (state.isHungry || state.isUnhappy) {
      weights[CatActivity.sitting] = 6;
      weights[CatActivity.walking] = 2;
    } else if (state.energy >= GameConfig.playMinEnergy &&
        state.happiness < GameConfig.playHappinessCeiling) {
      weights[CatActivity.playing] = 2;
    }

    if (previous != CatActivity.walking) weights.remove(previous);

    final activity = _pickWeighted(weights);
    switch (activity) {
      case CatActivity.walking:
        return const BehaviorChoice(CatActivity.walking, 0);
      case CatActivity.playing:
        return const BehaviorChoice(
            CatActivity.playing, GameConfig.autonomousPlaySeconds);
      default:
        return BehaviorChoice(
          activity,
          _range(GameConfig.behaviorMinSeconds, GameConfig.behaviorMaxSeconds),
        );
    }
  }

  /// How long the cat sleeps to recover to the wake-up energy level.
  double sleepDuration(CatState state) {
    final seconds = (GameConfig.sleepWakeEnergy - state.energy) /
        GameConfig.energyRecoveryPerSecond /
        GameConfig.statusTimeScale;
    return seconds
        .clamp(GameConfig.sleepMinSeconds, GameConfig.sleepMaxSeconds)
        .toDouble();
  }

  CatActivity _pickWeighted(Map<CatActivity, double> weights) {
    final total = weights.values.fold<double>(0, (a, b) => a + b);
    var roll = _random.nextDouble() * total;
    for (final entry in weights.entries) {
      roll -= entry.value;
      if (roll < 0) return entry.key;
    }
    return weights.keys.last;
  }

  double _range(double min, double max) =>
      min + _random.nextDouble() * (max - min);
}