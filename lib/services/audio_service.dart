import 'package:audioplayers/audioplayers.dart';
import '../models/sound_pack.dart';

/// Service for playing drum sounds with polyphonic support
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  // Pool of audio players for polyphonic playback
  static const int _poolSize = 12;
  final List<AudioPlayer> _playerPool = [];
  int _currentPlayerIndex = 0;
  bool _isInitialized = false;

  // Current sound pack
  SoundPack _currentPack = SoundPack.hipHop;

  /// Get the current sound pack
  SoundPack get currentPack => _currentPack;

  /// Initialize audio players
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Audio context configuration for concurrent playback
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {AVAudioSessionOptions.mixWithOthers},
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none, // Don't steal audio focus
      ),
    );

    // Create a pool of audio players for polyphonic playback
    for (int i = 0; i < _poolSize; i++) {
      final player = AudioPlayer();
      // Configure audio context to allow mixing
      await player.setAudioContext(audioContext);
      // Use release mode to allow sounds to complete naturally
      await player.setReleaseMode(ReleaseMode.release);
      _playerPool.add(player);
    }

    _isInitialized = true;
  }

  /// Switch to a different sound pack
  Future<void> switchSoundPack(SoundPack pack) async {
    _currentPack = pack;
    // Stop all current sounds when switching packs
    for (final player in _playerPool) {
      await player.stop();
    }
  }

  /// Play sound for the given pad index (0-11)
  /// Uses round-robin player selection from pool for polyphonic playback
  Future<void> playSound(int padIndex) async {
    if (!_isInitialized || padIndex < 0 || padIndex >= 12) {
      return;
    }

    // Get next available player from pool (round-robin)
    final player = _playerPool[_currentPlayerIndex];
    _currentPlayerIndex = (_currentPlayerIndex + 1) % _poolSize;

    final soundFile =
        _currentPack.soundFiles[padIndex % _currentPack.soundFiles.length];

    // Stop this player if it's still playing, then play the new sound
    await player.stop();
    await player.play(AssetSource(soundFile));
  }

  /// Dispose all audio players
  Future<void> dispose() async {
    for (final player in _playerPool) {
      await player.dispose();
    }
    _playerPool.clear();
    _isInitialized = false;
  }
}
