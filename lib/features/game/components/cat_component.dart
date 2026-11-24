import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/config/game_config.dart';
import '../../../core/constants/game_constants.dart';
import '../../cat/models/cat_activity.dart';
import '../../cat/services/cat_service.dart';
import '../../room/models/iso_grid.dart';
import '../systems/cat_behavior_system.dart';

/// Called whenever the cat's activity or current tile changes.
typedef CatStatusCallback = void Function(CatActivity activity, GridPoint cell);

/// Placeholder cat drawn with canvas shapes.
///
/// Runs a small activity state machine: it stays in an activity for a
/// duration, then asks [CatBehaviorSystem] what to do next. Player
/// interactions interrupt whatever it is doing and play in place.
///
/// `position` is the cat's feet (anchor = bottom center), on a tile center.
class CatComponent extends PositionComponent {
  CatComponent({
    required this.grid,
    required this.catService,
    required GridPoint startCell,
    required this.onStatusChanged,
    CatBehaviorSystem? behavior,
    Random? random,
  })  : _cell = startCell,
        _reportedCell = startCell,
        _random = random ?? Random(),
        _behavior = behavior ?? CatBehaviorSystem(random: random),
        super(
          size: Vector2(60, 50),
          anchor: Anchor.bottomCenter,
          priority: 10, // Phase 4 replaces this with depth sorting.
        ) {
    final p = grid.gridToWorld(startCell);
    position = Vector2(p.dx, p.dy);
    _activityTimer = 1.0;
  }

  final IsoGrid grid;
  final CatService catService;
  final CatStatusCallback onStatusChanged;
  final Random _random;
  final CatBehaviorSystem _behavior;

  GridPoint _cell;
  GridPoint _reportedCell;
  CatActivity _activity = CatActivity.idle;
  CatActivity _reportedActivity = CatActivity.idle;

  Vector2? _targetPosition;
  GridPoint? _targetCell;
  double _activityTimer = 0;
  double _reactionTimer = 0;
  double _animTime = 0;
  bool _facingRight = true;
  bool _interacting = false;

  // Reused paints (avoid allocating every frame).
  final Paint _shadow = Paint()..color = GameColors.shadow;
  final Paint _body = Paint()..color = GameColors.catBody;
  final Paint _dark = Paint()..color = GameColors.catDark;
  final Paint _earInner = Paint()..color = GameColors.catEarInner;
  final Paint _feature = Paint()..color = GameColors.catFeature;
  final Paint _bowl = Paint()..color = GameColors.bowl;
  final Paint _bowlInner = Paint()..color = GameColors.bowlInner;
  final Paint _toy = Paint()..color = GameColors.toy;
  final Paint _heartPaint = Paint();
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
  final Paint _zPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.6
    ..strokeCap = StrokeCap.round;
  final Path _heart = _buildHeart(5);

  // ---------------------------------------------------------------- public

  /// Player tap: walk to [cell]. Returns false if ignored (outside the room
  /// or the cat is busy with an interaction).
  bool walkTo(GridPoint cell) {
    if (_interacting || !grid.contains(cell)) return false;
    _startWalking(cell);
    return true;
  }

  /// Player interaction: interrupt the current activity and play it in place.
  void startInteraction(CatInteraction type, double seconds) {
    _trackCell();
    _targetPosition = null;
    _targetCell = null;
    _interacting = true;
    _activityTimer = seconds;
    _reactionTimer = seconds;
    _activity = switch (type) {
      CatInteraction.feed => CatActivity.eating,
      CatInteraction.pet => CatActivity.sitting,
      CatInteraction.play => CatActivity.playing,
    };
  }

  // ---------------------------------------------------------------- update

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;
    if (_reactionTimer > 0) _reactionTimer -= dt;

    catService.tick(dt, _activity);

    if (_activity == CatActivity.walking) {
      final target = _targetPosition;
      if (target == null) {
        _setActivity(CatActivity.idle, 1);
      } else {
        _moveToward(target, dt);
      }
    } else {
      _activityTimer -= dt;
      if (_activityTimer <= 0) {
        _interacting = false;
        _decideNext();
      }
    }

    _reportIfChanged();
  }

  void _decideNext() {
    _activityTimer = GameConfig.behaviorMinSeconds; // safety net
    final choice = _behavior.choose(catService.state, previous: _activity);
    if (choice.activity == CatActivity.walking) {
      _walkToRandomCell();
      return;
    }
    _setActivity(choice.activity, choice.durationSeconds);
  }

  void _setActivity(CatActivity activity, double seconds) {
    _activity = activity;
    _activityTimer = seconds;
  }

  void _walkToRandomCell() {
    if (grid.columns * grid.rows <= 1) return;
    GridPoint target;
    do {
      target = GridPoint(
        _random.nextInt(grid.columns),
        _random.nextInt(grid.rows),
      );
    } while (target == _cell);
    _startWalking(target);
  }

  void _startWalking(GridPoint cell) {
    final p = grid.gridToWorld(cell);
    _targetCell = cell;
    _targetPosition = Vector2(p.dx, p.dy);
    _activity = CatActivity.walking;
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
    _trackCell();
  }

  void _arrive() {
    final cell = _targetCell;
    if (cell != null) _cell = cell;
    _targetCell = null;
    _targetPosition = null;
    _setActivity(
      CatActivity.idle,
      GameConfig.behaviorMinSeconds +
          _random.nextDouble() *
              (GameConfig.behaviorMaxSeconds - GameConfig.behaviorMinSeconds),
    );
  }

  void _trackCell() {
    final current = grid.worldToGrid(Offset(position.x, position.y));
    if (current != null) _cell = current;
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
    final t = _animTime;
    final dir = _facingRight ? 1.0 : -1.0;
    final sleeping = _activity == CatActivity.sleeping;

    // Shadow stays on the ground (not flipped, not bobbing).
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y - 1),
        width: sleeping ? 44 : 34,
        height: 10,
      ),
      _shadow,
    );

    canvas.save();
    canvas.translate(size.x / 2, size.y);
    if (!_facingRight) canvas.scale(-1, 1);
    switch (_activity) {
      case CatActivity.sleeping:
        _drawSleeping(canvas, t);
        break;
      case CatActivity.sitting:
        _drawSitting(canvas, t);
        break;
      default:
        _drawStanding(canvas, t);
    }
    canvas.restore();

    // Overlays are drawn unmirrored so shapes never flip.
    canvas.save();
    canvas.translate(size.x / 2, size.y);
    if (sleeping) _drawSleepZs(canvas, t, dir);
    if (_reactionTimer > 0) _drawHearts(canvas, t);
    canvas.restore();
  }

  void _drawStanding(Canvas canvas, double t) {
    final walking = _activity == CatActivity.walking;
    final playing = _activity == CatActivity.playing;
    final eating = _activity == CatActivity.eating;
    final lively = walking || playing;

    final speed = playing ? 18.0 : 14.0;
    final bob = lively
        ? -sin(t * speed).abs() * (playing ? 6 : 3)
        : sin(t * 2) * 0.8;
    final wag = sin(t * (lively ? 10 : 3)) * 6;
    final stride = walking ? sin(t * 14) * 4 : 0.0;

    if (eating) _drawBowl(canvas);

    canvas.save();
    canvas.translate(0, bob);

    canvas.drawPath(
      Path()
        ..moveTo(-14, -16)
        ..quadraticBezierTo(-30, -16 + wag, -24, -36 + wag),
      _tail,
    );

    canvas.drawOval(
      Rect.fromCenter(center: Offset(-9 + stride, -3), width: 8, height: 9),
      _dark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(9 - stride, -3), width: 8, height: 9),
      _dark,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -15), width: 32, height: 22),
      _body,
    );

    _drawHead(
      canvas,
      dx: eating ? 2 : 0,
      dy: eating ? 10 + sin(t * 8) * 1.5 : 0,
      eyesClosed: false,
      t: t,
    );
    canvas.restore();

    if (playing) _drawToy(canvas, t);
  }

  void _drawSitting(Canvas canvas, double t) {
    canvas.save();
    canvas.translate(0, sin(t * 2) * 0.6);

    canvas.drawPath(
      Path()
        ..moveTo(-12, -6)
        ..quadraticBezierTo(-28, -2, -22, -10),
      _tail,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-1, -14), width: 26, height: 28),
      _body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(7, -3), width: 8, height: 7),
      _dark,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(-1, -3), width: 8, height: 7),
      _dark,
    );
    _drawHead(canvas, dx: -3, dy: -2, eyesClosed: false, t: t);
    canvas.restore();
  }

  void _drawSleeping(Canvas canvas, double t) {
    canvas.save();
    canvas.translate(0, sin(t * 1.5) * 0.6);

    canvas.drawPath(
      Path()
        ..moveTo(-18, -8)
        ..quadraticBezierTo(-22, 0, -6, -2),
      _tail,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(0, -9), width: 40, height: 16),
      _body,
    );
    _drawHead(canvas, dx: 5, dy: 17, eyesClosed: true, t: t);
    canvas.restore();
  }

  void _drawHead(
    Canvas canvas, {
    required double dx,
    required double dy,
    required bool eyesClosed,
    required double t,
  }) {
    canvas.save();
    canvas.translate(dx, dy);

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

    // Eyes (closed when asleep, brief blink every few seconds).
    final blinking = eyesClosed || (t % 4) > 3.85;
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

  void _drawBowl(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(25, -3), width: 18, height: 8),
      _bowl,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(25, -4), width: 13, height: 4),
      _bowlInner,
    );
  }

  void _drawToy(Canvas canvas, double t) {
    final y = -4 - sin(t * 8).abs() * 16;
    canvas.drawCircle(Offset(24, y), 4.5, _toy);
  }

  void _drawSleepZs(Canvas canvas, double t, double dir) {
    for (var i = 0; i < 2; i++) {
      final p = (t * 0.5 + i * 0.5) % 1.0;
      final s = 4.0 + i * 2;
      final alpha = ((1 - p) * 220).round().clamp(0, 255).toInt();
      _zPaint.color = GameColors.catFeature.withAlpha(alpha);
      final ox = dir * (14 + p * 10);
      final oy = -34 - p * 20;
      canvas.drawPath(
        Path()
          ..moveTo(ox, oy)
          ..lineTo(ox + s, oy)
          ..lineTo(ox, oy + s)
          ..lineTo(ox + s, oy + s),
        _zPaint,
      );
    }
  }

  void _drawHearts(Canvas canvas, double t) {
    for (var i = 0; i < 3; i++) {
      final p = (t * 0.9 + i / 3) % 1.0;
      final alpha = ((1 - p) * 255).round().clamp(0, 255).toInt();
      _heartPaint.color = GameColors.heart.withAlpha(alpha);
      canvas.save();
      canvas.translate(-12.0 + i * 12, -50 - p * 22);
      canvas.drawPath(_heart, _heartPaint);
      canvas.restore();
    }
  }

  static Path _buildHeart(double s) {
    return Path()
      ..moveTo(0, s)
      ..cubicTo(-s * 1.2, -s * 0.2, -s * 0.5, -s * 1.1, 0, -s * 0.4)
      ..cubicTo(s * 0.5, -s * 1.1, s * 1.2, -s * 0.2, 0, s)
      ..close();
  }
}