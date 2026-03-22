import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  bool _isMuted = false;
  bool _hapticEnabled = true;

  void setMuted(bool muted) {
    _isMuted = muted;
  }

  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
  }

  Future<void> playPointUp() async {
    if (_isMuted) return;
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> playPointDown() async {
    if (_isMuted) return;
    if (_hapticEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  Future<void> playMatchStart() async {
    if (_isMuted) return;
    if (_hapticEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  Future<void> playMatchEnd() async {
    if (_isMuted) return;
    if (_hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> playMVP() async {
    if (_isMuted) return;
    if (_hapticEnabled) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.heavyImpact();
    }
  }

  void dispose() {}
}
