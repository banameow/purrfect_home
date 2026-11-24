import 'package:flutter_test/flutter_test.dart';
// If your package is not called purrfect_home, change these imports.
import 'package:purrfect_home/core/config/game_config.dart';
import 'package:purrfect_home/features/cat/models/cat_activity.dart';
import 'package:purrfect_home/features/cat/models/cat_state.dart';
import 'package:purrfect_home/features/cat/services/cat_service.dart';

void main() {
  group('CatState', () {
    test('clamps values to the configured range', () {
      final s = CatState(hunger: 500, energy: -20);
      expect(s.hunger, GameConfig.statusMax);
      expect(s.energy, GameConfig.statusMin);
      s.happiness = 1000;
      s.affection = -5;
      expect(s.happiness, GameConfig.statusMax);
      expect(s.affection, GameConfig.statusMin);
    });

    test('low-status flags use the threshold', () {
      final s = CatState(hunger: 10, energy: 90, happiness: 90);
      expect(s.isHungry, isTrue);
      expect(s.isTired, isFalse);
      expect(s.isUnhappy, isFalse);
    });
  });

  group('CatService.interact', () {
    test('feeding raises hunger, happiness and affection', () {
      final service = CatService(
        initialState: CatState(hunger: 50, happiness: 50, affection: 0),
      );
      final result = service.interact(CatInteraction.feed);
      expect(result.accepted, isTrue);
      expect(result.durationSeconds, GameConfig.feedSeconds);
      expect(service.state.hunger,
          closeTo(50 + GameConfig.feedHungerGain, 0.001));
      expect(service.state.happiness,
          closeTo(50 + GameConfig.feedHappinessGain, 0.001));
      expect(service.state.affection,
          closeTo(GameConfig.feedAffectionGain, 0.001));
    });

    test('feeding a full cat is rejected and changes nothing', () {
      final service = CatService(initialState: CatState(hunger: 100));
      final result = service.interact(CatInteraction.feed);
      expect(result.accepted, isFalse);
      expect(service.state.hunger, 100);
      expect(service.isBusy, isFalse);
    });

    test('feeding never pushes hunger above the maximum', () {
      final service = CatService(initialState: CatState(hunger: 85));
      service.interact(CatInteraction.feed);
      expect(service.state.hunger, GameConfig.statusMax);
    });

    test('petting raises happiness and affection', () {
      final service =
          CatService(initialState: CatState(happiness: 40, affection: 0));
      expect(service.interact(CatInteraction.pet).accepted, isTrue);
      expect(service.state.happiness,
          closeTo(40 + GameConfig.petHappinessGain, 0.001));
      expect(service.state.affection,
          closeTo(GameConfig.petAffectionGain, 0.001));
    });

    test('playing costs energy and hunger but raises happiness', () {
      final service = CatService(
        initialState: CatState(energy: 80, hunger: 80, happiness: 40),
      );
      expect(service.interact(CatInteraction.play).accepted, isTrue);
      expect(service.state.energy,
          closeTo(80 - GameConfig.playEnergyCost, 0.001));
      expect(service.state.hunger,
          closeTo(80 - GameConfig.playHungerCost, 0.001));
      expect(service.state.happiness,
          closeTo(40 + GameConfig.playHappinessGain, 0.001));
    });

    test('a tired cat refuses to play', () {
      final service = CatService(initialState: CatState(energy: 5));
      final result = service.interact(CatInteraction.play);
      expect(result.accepted, isFalse);
      expect(service.state.energy, 5);
    });

    test('interactions are rejected while busy, allowed afterwards', () {
      final service = CatService();
      expect(service.interact(CatInteraction.pet).accepted, isTrue);
      expect(service.isBusy, isTrue);
      expect(service.interact(CatInteraction.pet).accepted, isFalse);

      service.tick(GameConfig.petSeconds + 0.1, CatActivity.sitting);
      expect(service.isBusy, isFalse);
      expect(service.interact(CatInteraction.pet).accepted, isTrue);
    });
  });

  group('CatService.tick', () {
    test('hunger and energy fall while the cat is awake', () {
      final service = CatService();
      final hunger = service.state.hunger;
      final energy = service.state.energy;
      service.tick(1, CatActivity.idle);
      expect(service.state.hunger, lessThan(hunger));
      expect(service.state.energy, lessThan(energy));
    });

    test('energy recovers while sleeping', () {
      final service = CatService(initialState: CatState(energy: 30));
      service.tick(1, CatActivity.sleeping);
      expect(service.state.energy, greaterThan(30));
    });

    test('hunger falls slower while sleeping', () {
      final awake = CatService(initialState: CatState(hunger: 80));
      final asleep = CatService(initialState: CatState(hunger: 80));
      awake.tick(1, CatActivity.idle);
      asleep.tick(1, CatActivity.sleeping);
      expect(asleep.state.hunger, greaterThan(awake.state.hunger));
    });

    test('playing drains energy faster than idling', () {
      final idle = CatService(initialState: CatState(energy: 80));
      final playing = CatService(initialState: CatState(energy: 80));
      idle.tick(1, CatActivity.idle);
      playing.tick(1, CatActivity.playing);
      expect(playing.state.energy, lessThan(idle.state.energy));
    });

    test('a hungry cat loses happiness faster', () {
      final fed = CatService(
        initialState: CatState(hunger: 80, energy: 80, happiness: 50),
      );
      final hungry = CatService(
        initialState: CatState(hunger: 10, energy: 80, happiness: 50),
      );
      fed.tick(1, CatActivity.idle);
      hungry.tick(1, CatActivity.idle);
      expect(hungry.state.happiness, lessThan(fed.state.happiness));
    });

    test('values never go below the minimum', () {
      final service = CatService(
        initialState: CatState(hunger: 0, energy: 0, happiness: 0),
      );
      service.tick(100, CatActivity.idle);
      expect(service.state.hunger, GameConfig.statusMin);
      expect(service.state.happiness, GameConfig.statusMin);
    });
  });
}