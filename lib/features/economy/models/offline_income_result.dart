/// The outcome of an offline income calculation.
class OfflineIncomeResult {
  const OfflineIncomeResult({
    required this.awayDuration,
    required this.creditedDuration,
    required this.coins,
  });

  /// Nothing earned (no time away, clock moved backwards, ...).
  static const OfflineIncomeResult none = OfflineIncomeResult(
    awayDuration: Duration.zero,
    creditedDuration: Duration.zero,
    coins: 0,
  );

  /// How long the player was away.
  final Duration awayDuration;

  /// The part of [awayDuration] that counts toward income (after the cap).
  final Duration creditedDuration;

  /// Whole coins earned (or, after applying, actually added to the jar).
  final int coins;

  /// True when the player was away longer than the offline income cap.
  bool get wasCapped =>
      creditedDuration > Duration.zero && awayDuration > creditedDuration;
}
