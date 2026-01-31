import 'package:audioplayers/audioplayers.dart';
import '../models/background_track.dart';

/// Service for playing background beat tracks using local assets
class BackgroundMusicService {
  static final BackgroundMusicService _instance =
      BackgroundMusicService._internal();
  factory BackgroundMusicService() => _instance;
  BackgroundMusicService._internal();

  final AudioPlayer _player = AudioPlayer();
  BackgroundTrack? _currentTrack;
  bool _isInitialized = false;
  bool _isPlaying = false;
  double _volume = 0.5;

  /// Current playing track
  BackgroundTrack? get currentTrack => _currentTrack;

  /// Whether music is currently playing
  bool get isPlaying => _isPlaying;

  /// Current volume (0.0 to 1.0)
  double get volume => _volume;

  /// Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Configure audio context to allow mixing with other audio sources
    await _player.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.none, // Don't request audio focus
        ),
      ),
    );

    await _player.setVolume(_volume);
    await _player.setReleaseMode(ReleaseMode.loop);

    // Listen to player state changes
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
    });

    _isInitialized = true;
  }

  /// Load and play a track from assets
  Future<void> playTrack(BackgroundTrack track) async {
    if (!_isInitialized) await initialize();

    try {
      _currentTrack = track;
      await _player.stop();
      await _player.play(AssetSource(track.assetPath));
      _isPlaying = true;
    } catch (e) {
      _currentTrack = null;
      _isPlaying = false;
      rethrow;
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  /// Resume playback
  Future<void> play() async {
    if (_currentTrack != null) {
      await _player.resume();
      _isPlaying = true;
    }
  }

  /// Stop playback and clear current track
  Future<void> stop() async {
    await _player.stop();
    _currentTrack = null;
    _isPlaying = false;
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _player.setVolume(_volume);
  }

  /// Dispose the player
  Future<void> dispose() async {
    await _player.dispose();
    _isInitialized = false;
  }
}
