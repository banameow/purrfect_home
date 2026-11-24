/// Tunable gameplay and layout values.
///
/// Keep numbers here instead of scattering them through widgets/components.
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

  // --- Cat ---
  static const String catName = 'Mochi';
  static const int catStartColumn = 2;
  static const int catStartRow = 2;
  static const double catWalkSpeed = 60; // world pixels per second
  static const double catIdleMinSeconds = 1.5;
  static const double catIdleMaxSeconds = 4.0;
}
