import 'package:flutter/foundation.dart';

import '../../../core/config/game_config.dart';
import '../models/cat_activity.dart';
import '../models/cat_state.dart';

enum CatInteraction { feed, pet, play }

class InteractionResult {
  const InteractionResult.accepted(this.message, this.durationSeconds)
      : accepted = true;
  const InteractionResult.rejected(this.message)
      : accepted = false,
        durationSeconds = 0;

  final bool accepted;
  final String message;
  final double durationSeconds;
}

/// Owns the cat's status: time-based progression and player interactions.
/// UI widgets listen to this; it knows nothing about Flame or storage.
class CatService extends ChangeNotifier {
  CatService({CatState? initialState}) : state = initialState ?? CatState();

  final CatState state;

  bool _disposed = false;
  double _busySeconds = 0;
  double _sinceNotify = 0;

  /// True while an interaction animation is playing.
  bool get isBusy => _busySeconds > 0;

  /// Advances status values. Call every frame while the game is active.
  void tick(double dt, CatActivity activity) {
    final scaled = dt * GameConfig.statusTimeScale;
    final sleeping = activity == CatActivity.sleeping;
    final playing = activity == CatActivity.playing;

    state.hunger -= GameConfig.hungerDecayPerSecond *
        (sleeping ? GameConfig.sleepingHungerFactor : 1.0) *
        scaled;

    if (sleeping) {
      state.energy += GameConfig.energyRecoveryPerSecond * scaled;
    } else {
      state.energy -= GameConfig.energyDecayPerSecond *
          (playing ? GameConfig.playingEnergyFactor : 1.0) *
          scaled;
    }

    final neglected = state.isHungry || state.isTired;
    state.happiness -= GameConfig.happinessDecayPerSecond *
        (neglected ? GameConfig.neglectHappinessFactor : 1.0) *
        scaled;

    var notifyNow = false;
    if (_busySeconds > 0) {
      _busySeconds -= dt;
      if (_busySeconds <= 0) {
        _busySeconds = 0;
        notifyNow = true; // re-enable buttons immediately
      }
    }

    // Throttle UI updates to ~4 per second.
    _sinceNotify += dt;
    if (notifyNow || _sinceNotify >= 0.25) {
      _sinceNotify = 0;
      notifyListeners();
    }
  }

  InteractionResult interact(CatInteraction type) {
    if (isBusy) {
      return const InteractionResult.rejected(
          '${GameConfig.catName} is busy right now');
    }
    switch (type) {
      case CatInteraction.feed:
        return _feed();
      case CatInteraction.pet:
        return _pet();
      case CatInteraction.play:
        return _play();
    }
  }

  InteractionResult _feed() {
    if (state.hunger >= GameConfig.feedMaxHunger) {
      return const InteractionResult.rejected(
          '${GameConfig.catName} is not hungry right now');
    }
    state.hunger += GameConfig.feedHungerGain;
    state.happiness += GameConfig.feedHappinessGain;
    state.affection += GameConfig.feedAffectionGain;
    return _accept('Nom nom! ${GameConfig.catName} enjoyed the meal',
        GameConfig.feedSeconds);
  }

  InteractionResult _pet() {
    state.happiness += GameConfig.petHappinessGain;
    state.affection += GameConfig.petAffectionGain;
    return _accept('${GameConfig.catName} purrs happily', GameConfig.petSeconds);
  }

  InteractionResult _play() {
    if (state.energy < GameConfig.playMinEnergy) {
      return const InteractionResult.rejected(
          '${GameConfig.catName} is too tired to play');
    }
    state.energy -= GameConfig.playEnergyCost;
    state.hunger -= GameConfig.playHungerCost;
    state.happiness += GameConfig.playHappinessGain;
    state.affection += GameConfig.playAffectionGain;
    return _accept('${GameConfig.catName} had fun playing!',
        GameConfig.playSeconds);
  }

  InteractionResult _accept(String message, double seconds) {
    _busySeconds = seconds;
    _sinceNotify = 0;
    notifyListeners();
    return InteractionResult.accepted(message, seconds);
  }

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