/// Tunable gameplay and layout values.
///
/// Keep numbers here instead of scattering them through widgets/components.
/// All status values use a 0-100 scale where HIGHER IS BETTER
/// (Hunger 100 = full, Energy 100 = rested).
class GameConfig {
  GameConfig._();

  // --- Viewport (fixed resolution; Flame scales it to the real screen) ---
  static const double viewportWidth = 400;
  static const double viewportHeight = 700;

  // --- Room grid ---
  static const int roomColumns = 6;
  static const int roomRows = 6;
  static const double tileWidth = 60;
  static const double tileHeight = 30; // 2:1 isometric ratio
  static const double wallHeight = 100;
  static const double floorEdgeThickness = 10;

  // --- Cat basics ---
  static const String catName = 'Mochi';
  static const int catStartColumn = 2;
  static const int catStartRow = 2;
  static const double catWalkSpeed = 60; // world pixels per second

  // --- Status scale ---
  static const double statusMin = 0;
  static const double statusMax = 100;
  static const double lowStatusThreshold = 25;
  static const double initialHunger = 80;
  static const double initialEnergy = 80;
  static const double initialHappiness = 70;
  static const double initialAffection = 0;

  // --- Progression (per second of active play) ---
  /// Multiplies status decay/recovery. Set to 10 to test quickly.
  static const double statusTimeScale = 1.0;
  static const double hungerDecayPerSecond = 0.25;
  static const double energyDecayPerSecond = 0.20;
  static const double energyRecoveryPerSecond = 3.0;
  static const double happinessDecayPerSecond = 0.10;
  static const double neglectHappinessFactor = 2.5; // hungry or tired
  static const double sleepingHungerFactor = 0.5;
  static const double playingEnergyFactor = 3.0;

  // --- Interactions ---
  static const double feedHungerGain = 30;
  static const double feedHappinessGain = 3;
  static const double feedAffectionGain = 1;
  static const double feedMaxHunger = 90; // refuses food above this
  static const double feedSeconds = 3;

  static const double petHappinessGain = 8;
  static const double petAffectionGain = 2;
  static const double petSeconds = 2;

  static const double playHappinessGain = 15;
  static const double playAffectionGain = 2;
  static const double playEnergyCost = 12;
  static const double playHungerCost = 4;
  static const double playMinEnergy = 20;
  static const double playSeconds = 4;

  static const double feedbackSeconds = 2.0;

  // --- Autonomous behavior ---
  static const double behaviorMinSeconds = 2.0;
  static const double behaviorMaxSeconds = 5.0;
  static const double autonomousPlaySeconds = 3.0;
  static const double sleepMinSeconds = 6.0;
  static const double sleepMaxSeconds = 30.0;
  static const double sleepWakeEnergy = 80;
  static const double playHappinessCeiling = 85;
}