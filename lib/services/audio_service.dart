import 'package:audioplayers/audioplayers.dart';

/// Service for playing drum sounds
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Audio players for each drum pad
  final List<AudioPlayer> _players = [];
  bool _isInitialized = false;

  // Drum sound file names
  final List<String> _soundFiles = [
    'assets/audio/d1.mp3',
    'assets/audio/d2.wav',
    'assets/audio/d3.wav',
    'assets/audio/d4.wav',
    'assets/audio/d5.wav',
    'assets/audio/d6.wav',
    'assets/audio/d7.wav',
    'assets/audio/d8.wav',
    'assets/audio/d9.wav',
  ];

  /// Initialize audio players
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Create audio players for each sound
    for (int i = 0; i < _soundFiles.length; i++) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop);
      _players.add(player);
    }

    _isInitialized = true;
  }

  /// Play sound for the given pad index (0-8)
  Future<void> playSound(int padIndex) async {
    if (!_isInitialized || padIndex < 0 || padIndex >= _players.length) {
      return;
    }

    final player = _players[padIndex];

    // Stop current playback and play from beginning
    await player.stop();
    await player.play(
      AssetSource(_soundFiles[padIndex].replaceFirst('assets/', '')),
    );
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
