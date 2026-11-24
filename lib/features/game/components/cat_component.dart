import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/config/game_config.dart';
import '../../../core/constants/game_constants.dart';
import '../../cat/models/cat_activity.dart';
import '../../room/models/iso_grid.dart';

/// Called whenever the cat's activity or current tile changes.
typedef CatStatusCallback = void Function(CatActivity activity, GridPoint cell);

/// Placeholder cat drawn with canvas shapes (no sprite assets needed yet).
///
/// Phase 1 behavior: walk to a tapped tile, otherwise wander to a random
/// tile after a short idle pause. Phase 2 replaces this with a proper
/// behavior system.
///
/// `position` is the cat's feet (anchor = bottom center), which sits on the
/// center of a tile.
class CatComponent extends PositionComponent {
  CatComponent({
    required this.grid,
    required GridPoint startCell,
    required this.onStatusChanged,
    Random? random,
  })  : _cell = startCell,
        _reportedCell = startCell,
        _random = random ?? Random(),
        super(
          size: Vector2(60, 50),
          anchor: Anchor.bottomCenter,
          priority: 10, // Phase 4 replaces this with depth sorting.
        ) {
    final p = grid.gridToWorld(startCell);
    position = Vector2(p.dx, p.dy);
    _idleTimer = 1.0;
  }

  final IsoGrid grid;
  final CatStatusCallback onStatusChanged;
  final Random _random;

  GridPoint _cell;
  GridPoint _reportedCell;
  CatActivity _activity = CatActivity.idle;
  CatActivity _reportedActivity = CatActivity.idle;

  Vector2? _targetPosition;
  GridPoint? _targetCell;
  double _idleTimer = 0;
  double _animTime = 0;
  bool _facingRight = true;

  // Reused paints (avoid allocating every frame).
  final Paint _shadow = Paint()..color = GameColors.shadow;
  final Paint _body = Paint()..color = GameColors.catBody;
  final Paint _dark = Paint()..color = GameColors.catDark;
  final Paint _earInner = Paint()..color = GameColors.catEarInner;
  final Paint _feature = Paint()..color = GameColors.catFeature;
  final Paint _tail = Paint()
    ..color = GameColors.catBody
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5
    ..strokeCap = StrokeCap.round;
  final Paint _blink = Paint()
    ..color = GameColors.catFeature
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5
    ..strokeCap = StrokeCap.round;

  // ---------------------------------------------------------------- public

  /// Walk to [cell]. Ignored if the tile is outside the room.
  void walkTo(GridPoint cell) {
    if (!grid.contains(cell)) return;
    final p = grid.gridToWorld(cell);
    _targetCell = cell;
    _targetPosition = Vector2(p.dx, p.dy);
    _activity = CatActivity.walking;
  }

  /// Walk to a random tile different from the current one.
  void walkToRandomCell() {
    if (grid.columns * grid.rows <= 1) return;
    GridPoint target;
    do {
      target = GridPoint(
        _random.nextInt(grid.columns),
        _random.nextInt(grid.rows),
      );
    } while (target == _cell);
    walkTo(target);
  }

  // ---------------------------------------------------------------- update

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;

    final target = _targetPosition;
    if (target != null) {
      _moveToward(target, dt);
    } else {
      _idleTimer -= dt;
      if (_idleTimer <= 0) walkToRandomCell();
    }

    _reportIfChanged();
  }

  void _moveToward(Vector2 target, double dt) {
    final delta = target - position;
    final distance = delta.length;
    final step = GameConfig.catWalkSpeed * dt;

    if (distance <= step) {
      position.setFrom(target);
      _arrive();
      return;
    }

    position.add(delta.normalized() * step);
    if (delta.x.abs() > 0.5) _facingRight = delta.x > 0;

    final current = grid.worldToGrid(Offset(position.x, position.y));
    if (current != null) _cell = current;
  }

  void _arrive() {
    final cell = _targetCell;
    if (cell != null) _cell = cell;
    _targetCell = null;
    _targetPosition = null;
    _activity = CatActivity.idle;
    _idleTimer = GameConfig.catIdleMinSeconds +
        _random.nextDouble() *
            (GameConfig.catIdleMaxSeconds - GameConfig.catIdleMinSeconds);
  }

  void _reportIfChanged() {
    if (_activity == _reportedActivity && _cell == _reportedCell) return;
    _reportedActivity = _activity;
    _reportedCell = _cell;
    onStatusChanged(_activity, _cell);
  }

  // ---------------------------------------------------------------- render

  @override
  void render(Canvas canvas) {
    final walking = _activity == CatActivity.walking;
    final t = _animTime;

    // Shadow stays on the ground (not flipped, not bobbing).
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 1),
        width: 34,
        height: 10,
      ),
      _shadow,
    );

    canvas.save();
    canvas.translate(size.x / 2, size.y);
    if (!_facingRight) canvas.scale(-1, 1);

    // Walking: quick hop. Idle: slow breathing.
    final bob = walking ? -sin(t * 14).abs() * 3 : sin(t * 2) * 0.8;
    canvas.translate(0, bob);

    // Tail (wags faster while walking).
    final wag = sin(t * (walking ? 10 : 3)) * 6;
    final tail = Path()
      ..moveTo(-14, -16)
      ..quadraticBezierTo(-30, -16 + wag, -24, -36 + wag);
    canvas.drawPath(tail, _tail);

    // Legs (alternate while walking).
    final stride = walking ? sin(t * 14) * 4 : 0.0;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(-9 + stride, -3), width: 8, height: 9),
      _dark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(9 - stride, -3), width: 8, height: 9),
      _dark,
    );

    // Body.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -15), width: 32, height: 22),
      _body,
    );

    // Ears.
    canvas.drawPath(
      Path()
        ..moveTo(3, -31)
        ..lineTo(5, -43)
        ..lineTo(12, -35)
        ..close(),
      _body,
    );
    canvas.drawPath(
      Path()
        ..moveTo(10, -35)
        ..lineTo(17, -43)
        ..lineTo(20, -30)
        ..close(),
      _body,
    );
    canvas.drawPath(
      Path()
        ..moveTo(5.5, -34)
        ..lineTo(6.2, -40)
        ..lineTo(10, -35.5)
        ..close(),
      _earInner,
    );
    canvas.drawPath(
      Path()
        ..moveTo(12, -35.5)
        ..lineTo(16.5, -40)
        ..lineTo(18.5, -32)
        ..close(),
      _earInner,
    );

    // Head.
    canvas.drawCircle(const Offset(11, -27), 10, _body);

    // Eyes (blink briefly every few seconds).
    final blinking = (t % 4) > 3.85;
    if (blinking) {
      canvas.drawLine(const Offset(6.5, -28), const Offset(9.5, -28), _blink);
      canvas.drawLine(const Offset(13.5, -28), const Offset(16.5, -28), _blink);
    } else {
      canvas.drawCircle(const Offset(8, -28), 1.7, _feature);
      canvas.drawCircle(const Offset(15, -28), 1.7, _feature);
    }

    // Nose.
    canvas.drawCircle(const Offset(19, -25), 1.4, _earInner);

    canvas.restore();
  }
}
