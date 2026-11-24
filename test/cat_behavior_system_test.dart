import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
// If your package is not called purrfect_home, change these imports.
import 'package:purrfect_home/core/config/game_config.dart';
import 'package:purrfect_home/features/cat/models/cat_activity.dart';
import 'package:purrfect_home/features/cat/models/cat_state.dart';
import 'package:purrfect_home/features/game/systems/cat_behavior_system.dart';

void main() {
  CatBehaviorSystem system([int seed = 1]) =>
      CatBehaviorSystem(random: Random(seed));

  group('CatBehaviorSystem', () {
    test('a tired cat chooses to sleep', () {
      final choice = system().choose(
        CatState(energy: 10),
        previous: CatActivity.idle,
      );
      expect(choice.activity, CatActivity.sleeping);
      expect(choice.durationSeconds, greaterThan(0));
    });

    test('sleep duration stays within limits and grows with tiredness', () {
      final s = system();
      final veryTired = s.sleepDuration(CatState(energy: 5));
      final slightlyTired = s.sleepDuration(CatState(energy: 60));
      expect(veryTired, greaterThanOrEqualTo(slightlyTired));
      for (final d in [veryTired, slightlyTired]) {
        expect(d, greaterThanOrEqualTo(GameConfig.sleepMinSeconds));
        expect(d, lessThanOrEqualTo(GameConfig.sleepMaxSeconds));
      }
    });

    test('never repeats the activity it just finished', () {
      final healthy = CatState(hunger: 80, energy: 80, happiness: 50);
      for (var seed = 0; seed < 200; seed++) {
        final choice = system(seed).choose(healthy, previous: CatActivity.idle);
        expect(choice.activity, isNot(CatActivity.idle));
      }
    });

    test('a hungry cat never starts playing', () {
      final hungry = CatState(hunger: 10, energy: 80, happiness: 80);
      for (var seed = 0; seed < 300; seed++) {
        final choice = system(seed).choose(hungry, previous: CatActivity.eating);
        expect(choice.activity, isNot(CatActivity.playing));
        expect(choice.activity, isNot(CatActivity.sleeping));
      }
    });

    test('a rested cat can pick every non-sleep, non-eating activity', () {
      final rested = CatState(hunger: 80, energy: 80, happiness: 50);
      final seen = <CatActivity>{};
      for (var seed = 0; seed < 500; seed++) {
        seen.add(system(seed)
            .choose(rested, previous: CatActivity.eating)
            .activity);
      }
      expect(
        seen,
        {
          CatActivity.idle,
          CatActivity.walking,
          CatActivity.sitting,
          CatActivity.playing,
        },
      );
    });

    test('walking has no timer, other activities have valid durations', () {
      final rested = CatState(hunger: 80, energy: 80, happiness: 50);
      for (var seed = 0; seed < 300; seed++) {
        final choice =
            system(seed).choose(rested, previous: CatActivity.eating);
        if (choice.activity == CatActivity.walking) {
          expect(choice.durationSeconds, 0);
        } else {
          expect(choice.durationSeconds,
              greaterThanOrEqualTo(GameConfig.behaviorMinSeconds));
          expect(choice.durationSeconds,
              lessThanOrEqualTo(GameConfig.behaviorMaxSeconds));
        }
      }
    });
  });
}