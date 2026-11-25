/// All tunable economy values in one place.
///
/// Nothing in the UI or game components should hardcode a coin amount or a
/// rate: they read it from here (through [EconomyService]). Tests can pass a
/// custom config to get easy numbers.
///
/// These defaults are placeholders; they get balanced in Phase 5 once shop
/// prices exist.
class EconomyConfig {
  const EconomyConfig({
    this.startingCoins = 50,
    this.passiveCoinsPerMinute = 3.0,
    this.pendingCoinsCap = 600,
    this.offlineRateMultiplier = 0.5,
    this.maxOfflineDuration = const Duration(hours: 6),
    this.minOfflineDuration = const Duration(minutes: 1),
    this.timeScale = 1.0,
  });

  static const EconomyConfig defaults = EconomyConfig();

  /// Coins in the wallet on a brand-new save.
  final int startingCoins;

  /// Passive income while the game is being played.
  final double passiveCoinsPerMinute;

  /// Capacity of the "coin jar" (coins waiting to be collected). Stops the
  /// player from earning unlimited coins by leaving the app open.
  final int pendingCoinsCap;

  /// Offline income = active rate x this multiplier (0.5 = half speed).
  final double offlineRateMultiplier;

  /// Time away beyond this earns nothing extra (the offline income cap).
  final Duration maxOfflineDuration;

  /// Absences shorter than this earn nothing (ignores quick app switches).
  final Duration minOfflineDuration;

  /// Multiplies elapsed time for income (active ticks AND time away).
  /// Keep 1.0 in production; set e.g. 60 to test quickly.
  final double timeScale;
}
