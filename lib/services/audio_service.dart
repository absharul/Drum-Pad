import 'package:audioplayers/audioplayers.dart';
import '../models/sound_pack.dart';

/// Service for playing drum sounds with sound pack support
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players for each drum pad
  final List<AudioPlayer> _players = [];
  bool _isInitialized = false;

  // Current sound pack
  SoundPack _currentPack = SoundPack.hipHop;

  /// Get the current sound pack
  SoundPack get currentPack => _currentPack;

  /// Initialize audio players
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Create audio players for each sound (12 pads)
    for (int i = 0; i < 12; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _players.add(player);
    }

    _isInitialized = true;
  }

  /// Switch to a different sound pack
  Future<void> switchSoundPack(SoundPack pack) async {
    _currentPack = pack;
    // Stop all current sounds when switching
    for (final player in _players) {
      await player.stop();
    }
  }

  /// Play sound for the given pad index (0-11)
  Future<void> playSound(int padIndex) async {
    if (!_isInitialized || padIndex < 0 || padIndex >= _players.length) {
      return;
    }

    final player = _players[padIndex];
    final soundFile =
        _currentPack.soundFiles[padIndex % _currentPack.soundFiles.length];

    // Stop current playback and play from beginning
    await player.stop();
    await player.play(AssetSource(soundFile));
  }

  /// Dispose all audio players
  Future<void> dispose() async {
    for (final player in _players) {
      await player.dispose();
    }
    _players.clear();
    _isInitialized = false;
  }
}
