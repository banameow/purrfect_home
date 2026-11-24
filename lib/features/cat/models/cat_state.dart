import '../../../core/config/game_config.dart';

/// The cat's status values. All are clamped to the configured range.
/// Higher is better for every value.
class CatState {
  CatState({
    double? hunger,
    double? energy,
    double? happiness,
    double? affection,
  })  : _hunger = _clamp(hunger ?? GameConfig.initialHunger),
        _energy = _clamp(energy ?? GameConfig.initialEnergy),
        _happiness = _clamp(happiness ?? GameConfig.initialHappiness),
        _affection = _clamp(affection ?? GameConfig.initialAffection);

  double _hunger;
  double _energy;
  double _happiness;
  double _affection;

  double get hunger => _hunger;
  set hunger(double v) => _hunger = _clamp(v);

  double get energy => _energy;
  set energy(double v) => _energy = _clamp(v);

  double get happiness => _happiness;
  set happiness(double v) => _happiness = _clamp(v);

  /// Long-term value; only goes up through positive interactions.
  double get affection => _affection;
  set affection(double v) => _affection = _clamp(v);

  bool get isHungry => _hunger < GameConfig.lowStatusThreshold;
  bool get isTired => _energy < GameConfig.lowStatusThreshold;
  bool get isUnhappy => _happiness < GameConfig.lowStatusThreshold;

  static double _clamp(double v) =>
      v.clamp(GameConfig.statusMin, GameConfig.statusMax).toDouble();
}