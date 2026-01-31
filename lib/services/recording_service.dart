import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../models/settings_model.dart';

/// Service for recording and sharing audio
class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  factory RecordingService() => _instance;
  RecordingService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;
  RecordingSource _currentSource = RecordingSource.micOnly;

  // Stream controller for recording duration
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  Timer? _durationTimer;
  Duration _currentDuration = Duration.zero;

  /// Stream of recording duration updates
  Stream<Duration> get durationStream => _durationController.stream;

  /// Whether currently recording
  bool get isRecording => _isRecording;

  /// Path to the last recording
  String? get lastRecordingPath => _currentRecordingPath;

  /// Current recording source
  RecordingSource get currentSource => _currentSource;

  /// Initialize the recorder
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Request microphone permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      return false;
    }

    await _recorder.openRecorder();
    _isInitialized = true;
    return true;
  }

  /// Set the recording source for future recordings
  void setRecordingSource(RecordingSource source) {
    _currentSource = source;
  }

  /// Start recording with the current recording source setting
  Future<bool> startRecording({RecordingSource? source}) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isRecording) return false;

    // Use provided source or the current setting
    final recordingSource = source ?? _currentSource;

    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/drum_recording_$timestamp.aac';

      // Configure audio source based on recording source setting
      // Note: Device audio capture requires Android 10+ and special permissions
      AudioSource audioSource;
      switch (recordingSource) {
        case RecordingSource.micOnly:
          audioSource = AudioSource.microphone;
          break;
        case RecordingSource.deviceAudio:
          // Android 10+ supports media capture
          // On unsupported devices, this will fall back to microphone
          if (Platform.isAndroid) {
            audioSource =
                AudioSource.voice_call; // Best approximation for internal audio
          } else {
            audioSource = AudioSource.microphone;
          }
          break;
        case RecordingSource.mixed:
          // For mixed recording, we use mic but note that flutter_sound
          // doesn't directly support mixing - this is a limitation
          // Full implementation would require platform-specific code
          audioSource = AudioSource.microphone;
          break;
      }

      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
        audioSource: audioSource,
      );

      _isRecording = true;
      _currentDuration = Duration.zero;

      // Start duration timer
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _currentDuration += const Duration(seconds: 1);
        _durationController.add(_currentDuration);
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Stop recording
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      await _recorder.stopRecorder();
      _isRecording = false;

      // Stop duration timer
      _durationTimer?.cancel();
      _durationTimer = null;

      return _currentRecordingPath;
    } catch (e) {
      return null;
    }
  }

  /// Share the last recording
  Future<bool> shareRecording() async {
    if (_currentRecordingPath == null) return false;

    final file = File(_currentRecordingPath!);
    if (!await file.exists()) return false;

    try {
      await Share.shareXFiles(
        [XFile(_currentRecordingPath!)],
        text: 'Check out my drum beat! 🥁',
        subject: 'Drum Pad Recording',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete the last recording
  Future<void> deleteLastRecording() async {
    if (_currentRecordingPath == null) return;

    final file = File(_currentRecordingPath!);
    if (await file.exists()) {
      await file.delete();
    }
    _currentRecordingPath = null;
  }

  /// Dispose the recorder
  Future<void> dispose() async {
    _durationTimer?.cancel();
    await _durationController.close();

    if (_isRecording) {
      await stopRecording();
    }

    if (_isInitialized) {
      await _recorder.closeRecorder();
      _isInitialized = false;
    }
  }
}
