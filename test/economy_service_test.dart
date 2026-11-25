import 'package:flutter_test/flutter_test.dart';
// If your package is not called purrfect_home, change these imports.
import 'package:purrfect_home/features/economy/models/coin_wallet.dart';
import 'package:purrfect_home/features/economy/models/economy_config.dart';
import 'package:purrfect_home/features/economy/services/economy_service.dart';

void main() {
  // 60 coins/min = exactly 1 coin per second, which keeps the maths easy.
  const fast = EconomyConfig(
    startingCoins: 10,
    passiveCoinsPerMinute: 60,
    pendingCoinsCap: 5,
  );

  // Offline: 60/min x 0.5 = 30 coins per minute away, capped at 2 hours.
  const offline = EconomyConfig(
    startingCoins: 0,
    passiveCoinsPerMinute: 60,
    offlineRateMultiplier: 0.5,
    maxOfflineDuration: Duration(hours: 2),
    minOfflineDuration: Duration(minutes: 1),
    pendingCoinsCap: 100000,
  );

  final now = DateTime(2026, 1, 1, 12);

  group('CoinWallet', () {
    test('starts with the given balance, never negative', () {
      expect(CoinWallet(initialBalance: 25).balance, 25);
      expect(CoinWallet(initialBalance: -5).balance, 0);
    });

    test('add increases the balance', () {
      final wallet = CoinWallet(initialBalance: 5)..add(7);
      expect(wallet.balance, 12);
    });

    test('trySpend succeeds when affordable, including the exact balance', () {
      final wallet = CoinWallet(initialBalance: 10);
      expect(wallet.trySpend(4), isTrue);
      expect(wallet.balance, 6);
      expect(wallet.trySpend(6), isTrue);
      expect(wallet.balance, 0);
    });

    test('trySpend fails and changes nothing when too expensive', () {
      final wallet = CoinWallet(initialBalance: 5);
      expect(wallet.trySpend(6), isFalse);
      expect(wallet.balance, 5);
    });

    test('canAfford compares against the balance', () {
      final wallet = CoinWallet(initialBalance: 5);
      expect(wallet.canAfford(5), isTrue);
      expect(wallet.canAfford(6), isFalse);
    });

    test('negative amounts throw', () {
      final wallet = CoinWallet(initialBalance: 5);
      expect(() => wallet.add(-1), throwsArgumentError);
      expect(() => wallet.trySpend(-1), throwsArgumentError);
      expect(wallet.balance, 5);
    });
  });

  group('EconomyService wallet', () {
    test('starts with the configured starting coins', () {
      expect(EconomyService(config: fast).coins, 10);
      expect(EconomyService().coins, EconomyConfig.defaults.startingCoins);
    });

    test('earn adds coins and notifies; earning 0 does nothing', () {
      final service = EconomyService(config: fast);
      var notifications = 0;
      service.addListener(() => notifications++);

      service.earn(5);
      expect(service.coins, 15);
      expect(notifications, 1);

      service.earn(0);
      expect(service.coins, 15);
      expect(notifications, 1);

      expect(() => service.earn(-1), throwsArgumentError);
    });

    test('spend succeeds, fails and notifies only on success', () {
      final service = EconomyService(config: fast);
      var notifications = 0;
      service.addListener(() => notifications++);

      expect(service.spend(4), isTrue);
      expect(service.coins, 6);
      expect(notifications, 1);

      expect(service.spend(7), isFalse);
      expect(service.coins, 6);
      expect(notifications, 1);

      expect(service.canAfford(6), isTrue);
      expect(service.canAfford(7), isFalse);
    });
  });

  group('EconomyService passive income', () {
    test('tick fills the jar at the configured rate', () {
      final service = EconomyService(config: fast);
      service.tick(1);
      expect(service.pendingCoins, 1);
      service.tick(1);
      expect(service.pendingCoins, 2);
      expect(service.coins, 10); // wallet untouched until collected
    });

    test('partial coins accumulate across ticks', () {
      final service = EconomyService(config: fast);
      service.tick(0.5);
      expect(service.pendingCoins, 0);
      service.tick(0.5);
      expect(service.pendingCoins, 1);
    });

    test('notifies only when the whole-coin number changes', () {
      final service = EconomyService(config: fast);
      var notifications = 0;
      service.addListener(() => notifications++);

      service.tick(0.5);
      expect(notifications, 0);
      service.tick(0.5);
      expect(notifications, 1);
    });

    test('the jar never exceeds its capacity', () {
      final service = EconomyService(config: fast);
      for (var i = 0; i < 20; i++) {
        service.tick(1);
      }
      expect(service.pendingCoins, 5);
      expect(service.isPendingFull, isTrue);
    });

    test('a huge frame time cannot award a big chunk at once', () {
      final service = EconomyService(config: fast);
      service.tick(1000);
      expect(service.pendingCoins, 1); // clamped to 1 second
    });

    test('timeScale speeds income up', () {
      final service = EconomyService(
        config: const EconomyConfig(
          startingCoins: 0,
          passiveCoinsPerMinute: 1,
          timeScale: 60,
        ),
      );
      service.tick(1);
      expect(service.pendingCoins, 1);
    });
  });

  group('EconomyService collect', () {
    test('moves whole coins from the jar into the wallet', () {
      final service = EconomyService(config: fast);
      service.tick(1);
      service.tick(1);
      service.tick(1);

      expect(service.collect(), 3);
      expect(service.coins, 13);
      expect(service.pendingCoins, 0);
    });

    test('keeps the fractional remainder in the jar', () {
      final service = EconomyService(config: fast);
      service.tick(0.75);
      service.tick(0.75); // 1.5 coins

      expect(service.collect(), 1);
      expect(service.coins, 11);

      service.tick(0.5); // 0.5 + 0.5 = 1 coin again
      expect(service.pendingCoins, 1);
    });

    test('collecting an empty jar returns 0 and does not notify', () {
      final service = EconomyService(config: fast);
      var notifications = 0;
      service.addListener(() => notifications++);

      expect(service.collect(), 0);
      expect(service.coins, 10);
      expect(notifications, 0);
    });

    test('collecting a full jar lets it fill again', () {
      final service = EconomyService(config: fast);
      for (var i = 0; i < 10; i++) {
        service.tick(1);
      }
      expect(service.isPendingFull, isTrue);

      service.collect();
      expect(service.isPendingFull, isFalse);
      service.tick(1);
      expect(service.pendingCoins, 1);
    });
  });

  group('EconomyService offline income', () {
    test('pays the reduced offline rate for time away', () {
      final service = EconomyService(config: offline);
      final result = service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 10)),
        now: now,
      );
      expect(result.coins, 300); // 10 min x 30 coins/min
      expect(result.awayDuration, const Duration(minutes: 10));
      expect(result.creditedDuration, const Duration(minutes: 10));
      expect(result.wasCapped, isFalse);
    });

    test('time beyond the maximum duration earns nothing extra', () {
      final service = EconomyService(config: offline);
      final result = service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(hours: 5)),
        now: now,
      );
      expect(result.coins, 3600); // capped at 2 h x 60 min x 30
      expect(result.creditedDuration, const Duration(hours: 2));
      expect(result.awayDuration, const Duration(hours: 5));
      expect(result.wasCapped, isTrue);
    });

    test('a very long absence never exceeds the cap', () {
      final service = EconomyService(config: offline);
      final result = service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(days: 365)),
        now: now,
      );
      expect(result.coins, 3600);
      expect(result.wasCapped, isTrue);
    });

    test('very short absences earn nothing', () {
      final service = EconomyService(config: offline);
      final result = service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(seconds: 30)),
        now: now,
      );
      expect(result.coins, 0);
      expect(result.wasCapped, isFalse);
    });

    test('partial coins are rounded down', () {
      final service = EconomyService(
        config: const EconomyConfig(
          startingCoins: 0,
          passiveCoinsPerMinute: 3,
          offlineRateMultiplier: 0.5,
          pendingCoinsCap: 100000,
        ),
      );
      final result = service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 1, seconds: 1)),
        now: now,
      );
      expect(result.coins, 1); // 1.525 -> 1
    });

    test('a clock that moved backwards earns nothing', () {
      final service = EconomyService(config: offline);
      final result = service.calculateOfflineIncome(
        lastActive: now.add(const Duration(hours: 1)),
        now: now,
      );
      expect(result.coins, 0);
    });

    test('timeScale also scales time away', () {
      final service = EconomyService(
        config: const EconomyConfig(
          startingCoins: 0,
          passiveCoinsPerMinute: 1,
          offlineRateMultiplier: 1,
          timeScale: 60,
          pendingCoinsCap: 100000,
        ),
      );
      final result = service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 1)),
        now: now,
      );
      expect(result.coins, 60); // 1 real minute = 60 scaled minutes
    });

    test('calculating changes nothing', () {
      final service = EconomyService(config: offline);
      service.calculateOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 10)),
        now: now,
      );
      expect(service.pendingCoins, 0);
      expect(service.coins, 0);
    });

    test('applying adds the coins to the jar and notifies', () {
      final service = EconomyService(config: offline);
      var notifications = 0;
      service.addListener(() => notifications++);

      final result = service.applyOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 10)),
        now: now,
      );
      expect(result.coins, 300);
      expect(service.pendingCoins, 300);
      expect(service.coins, 0); // still needs to be collected
      expect(notifications, 1);
    });

    test('applying never overfills the jar', () {
      final service = EconomyService(
        config: const EconomyConfig(
          startingCoins: 0,
          passiveCoinsPerMinute: 60,
          offlineRateMultiplier: 0.5,
          pendingCoinsCap: 100,
        ),
      );
      final result = service.applyOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 10)),
        now: now,
      );
      expect(result.coins, 100); // 300 earned, only 100 fit
      expect(service.pendingCoins, 100);
    });

    test('applying only reports the coins that actually fit', () {
      final service = EconomyService(
        config: const EconomyConfig(
          startingCoins: 0,
          passiveCoinsPerMinute: 60,
          offlineRateMultiplier: 0.5,
          pendingCoinsCap: 100,
        ),
      );
      for (var i = 0; i < 40; i++) {
        service.tick(1); // 40 coins already in the jar
      }
      final result = service.applyOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 10)),
        now: now,
      );
      expect(result.coins, 60);
      expect(service.pendingCoins, 100);

      final again = service.applyOfflineIncome(
        lastActive: now.subtract(const Duration(minutes: 10)),
        now: now,
      );
      expect(again.coins, 0);
    });

    test('applying nothing does not notify', () {
      final service = EconomyService(config: offline);
      var notifications = 0;
      service.addListener(() => notifications++);

      service.applyOfflineIncome(
        lastActive: now.subtract(const Duration(seconds: 10)),
        now: now,
      );
      expect(notifications, 0);
    });
  });
}
