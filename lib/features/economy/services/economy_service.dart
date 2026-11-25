import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/coin_wallet.dart';
import '../models/economy_config.dart';
import '../models/offline_income_result.dart';

/// Owns the player's coins and all coin income.
///
/// - Passive income fills the "coin jar" (pending coins) while playing.
/// - Offline income is added to the same jar when the player returns.
/// - The player moves jar coins into the wallet with [collect].
/// - Task rewards use [earn] (wallet directly); the shop uses [spend].
///
/// It never reads the clock itself: callers pass times in, which keeps the
/// maths easy to test. UI widgets listen to it; it knows nothing about Flame.
class EconomyService extends ChangeNotifier {
  EconomyService({
    this.config = EconomyConfig.defaults,
    CoinWallet? wallet,
  }) : _wallet = wallet ?? CoinWallet(initialBalance: config.startingCoins);

  /// Frame-time spikes (lag, resuming) are clamped so they cannot award a
  /// big chunk of passive income at once.
  static const double _maxTickSeconds = 1.0;

  final EconomyConfig config;
  final CoinWallet _wallet;

  /// Coins waiting in the jar. Fractional so slow rates accumulate smoothly.
  double _pending = 0;
  bool _disposed = false;

  /// Coins in the wallet.
  int get coins => _wallet.balance;

  /// Whole coins waiting in the jar.
  int get pendingCoins => _pending.floor();

  int get pendingCap => config.pendingCoinsCap;

  bool get isPendingFull => pendingCoins >= pendingCap;

  bool canAfford(int amount) => _wallet.canAfford(amount);

  // ------------------------------------------------------- wallet changes

  /// Adds coins straight to the wallet (task rewards, gifts).
  /// Throws [ArgumentError] for a negative amount.
  void earn(int amount) {
    if (amount == 0) {
      return;
    }
    _wallet.add(amount);
    notifyListeners();
  }

  /// Spends coins. Returns false (and changes nothing) if too expensive.
  bool spend(int amount) {
    if (!_wallet.trySpend(amount)) return false;
    if (amount > 0) notifyListeners();
    return true;
  }

  // -------------------------------------------------------- passive income

  /// Adds passive income to the jar. Call every frame while the game is
  /// active (the Flame loop pauses while the app is in the background).
  void tick(double dt) {
    if (_disposed || dt <= 0 || isPendingFull) return;

    final seconds = min(dt, _maxTickSeconds);
    final before = pendingCoins;
    _pending = min(
      config.pendingCoinsCap.toDouble(),
      _pending + config.passiveCoinsPerMinute / 60 * seconds * config.timeScale,
    );

    // Only notify when the visible whole-coin number changes.
    if (pendingCoins != before) notifyListeners();
  }

  /// Moves all whole coins from the jar into the wallet.
  /// Returns how many coins were collected (0 if the jar is empty).
  int collect() {
    final amount = pendingCoins;
    if (amount <= 0) return 0;
    _wallet.add(amount);
    _pending -= amount; // keep the fractional remainder
    notifyListeners();
    return amount;
  }

  // ---------------------------------------------------------- offline income

  /// Works out offline income for the time between [lastActive] and [now].
  /// Pure calculation: changes nothing.
  ///
  /// - Clock moved backwards -> nothing.
  /// - Away less than [EconomyConfig.minOfflineDuration] -> nothing.
  /// - Only the first [EconomyConfig.maxOfflineDuration] counts (the cap).
  /// - Paid at passive rate x [EconomyConfig.offlineRateMultiplier].
  OfflineIncomeResult calculateOfflineIncome({
    required DateTime lastActive,
    required DateTime now,
  }) {
    final real = now.difference(lastActive);
    if (real.isNegative) return OfflineIncomeResult.none;

    final away = Duration(
      milliseconds: (real.inMilliseconds * config.timeScale).round(),
    );
    if (away < config.minOfflineDuration) {
      return OfflineIncomeResult(
        awayDuration: away,
        creditedDuration: Duration.zero,
        coins: 0,
      );
    }

    final credited =
        away > config.maxOfflineDuration ? config.maxOfflineDuration : away;
    final minutes = credited.inMilliseconds / Duration.millisecondsPerMinute;
    final coins = (minutes *
            config.passiveCoinsPerMinute *
            config.offlineRateMultiplier)
        .floor();

    return OfflineIncomeResult(
      awayDuration: away,
      creditedDuration: credited,
      coins: coins,
    );
  }

  /// Calculates offline income and adds it to the jar (never beyond the
  /// jar capacity). The returned result's `coins` is what was really added.
  OfflineIncomeResult applyOfflineIncome({
    required DateTime lastActive,
    required DateTime now,
  }) {
    final calculated = calculateOfflineIncome(lastActive: lastActive, now: now);
    if (calculated.coins <= 0) return calculated;

    final added = _addToJar(calculated.coins.toDouble());
    if (added > 0) notifyListeners();

    return OfflineIncomeResult(
      awayDuration: calculated.awayDuration,
      creditedDuration: calculated.creditedDuration,
      coins: added,
    );
  }

  /// Adds to the jar up to its capacity; returns whole coins actually added.
  int _addToJar(double amount) {
    final before = _pending;
    _pending = min(config.pendingCoinsCap.toDouble(), _pending + amount);
    return _pending.floor() - before.floor();
  }

  // ---------------------------------------------------------------- lifecycle

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
