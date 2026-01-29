import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Service for metronome functionality with configurable BPM
class MetronomeService {
  static final MetronomeService _instance = MetronomeService._internal();
  factory MetronomeService() => _instance;
  MetronomeService._internal();

  Timer? _timer;
  int _bpm = 120;
  int _currentBeat = 0;
  bool _isPlaying = false;
  bool _soundEnabled = true;
  AudioPlayer? _tickPlayer;

  // Stream controllers for beat updates
  final StreamController<int> _beatController =
      StreamController<int>.broadcast();

  /// Stream of beat updates (1-4)
  Stream<int> get beatStream => _beatController.stream;

  /// Current BPM value
  int get bpm => _bpm;

  /// Whether metronome is currently playing
  bool get isPlaying => _isPlaying;

  /// Whether sound is enabled
  bool get soundEnabled => _soundEnabled;

  /// Current beat (1-4)
  int get currentBeat => _currentBeat;

  /// Initialize the metronome
  Future<void> initialize() async {
    _tickPlayer = AudioPlayer();
    await _tickPlayer!.setReleaseMode(ReleaseMode.stop);
  }

  /// Set BPM value
  void setBpm(int newBpm) {
    _bpm = newBpm.clamp(40, 240);
    if (_isPlaying) {
      // Restart with new BPM
      stop();
      start();
    }
  }

  /// Toggle sound on/off
  void toggleSound() {
    _soundEnabled = !_soundEnabled;
  }

  /// Start the metronome
  void start() {
    if (_isPlaying) return;

    _isPlaying = true;
    _currentBeat = 0;

    final interval = Duration(milliseconds: (60000 / _bpm).round());

    _timer = Timer.periodic(interval, (_) {
      _currentBeat = (_currentBeat % 4) + 1;
      _beatController.add(_currentBeat);

      if (_soundEnabled) {
        _playTick();
      }
    });

    // Immediately fire first beat
    _currentBeat = 1;
    _beatController.add(_currentBeat);
    if (_soundEnabled) {
      _playTick();
    }
  }

  /// Stop the metronome
  void stop() {
    _timer?.cancel();
    _timer = null;
    _isPlaying = false;
    _currentBeat = 0;
    _beatController.add(0);
  }

  /// Toggle play/stop
  void toggle() {
    if (_isPlaying) {
      stop();
    } else {
      start();
    }
  }

  /// Play tick sound
  Future<void> _playTick() async {
    if (_tickPlayer != null) {
      await _tickPlayer!.stop();
      // Use a drum sound as metronome tick
      await _tickPlayer!.play(AssetSource('audio/d3.wav'), volume: 0.3);
    }
  }

  /// Tap tempo - call this method repeatedly to set BPM from tapping
  List<DateTime> _tapTimes = [];

  void tapTempo() {
    final now = DateTime.now();

    // Reset if last tap was more than 2 seconds ago
    if (_tapTimes.isNotEmpty &&
        now.difference(_tapTimes.last).inMilliseconds > 2000) {
      _tapTimes.clear();
    }

    _tapTimes.add(now);

    // Need at least 2 taps to calculate BPM
    if (_tapTimes.length >= 2) {
      // Calculate average interval from last 4 taps
      final recentTaps = _tapTimes.length > 4
          ? _tapTimes.sublist(_tapTimes.length - 4)
          : _tapTimes;

      int totalMs = 0;
      for (int i = 1; i < recentTaps.length; i++) {
        totalMs += recentTaps[i].difference(recentTaps[i - 1]).inMilliseconds;
      }

      final avgInterval = totalMs / (recentTaps.length - 1);
      final calculatedBpm = (60000 / avgInterval).round();

      setBpm(calculatedBpm);
    }

    // Keep only last 8 taps
    if (_tapTimes.length > 8) {
      _tapTimes = _tapTimes.sublist(_tapTimes.length - 8);
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    stop();
    await _beatController.close();
    await _tickPlayer?.dispose();
  }
}
