import 'dart:async';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Service for recording and sharing audio
class RecordingService {
  static final RecordingService _instance = RecordingService._internal();
  factory RecordingService() => _instance;
  RecordingService._internal();

  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isInitialized = false;
  bool _isRecording = false;
  String? _currentRecordingPath;

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

  /// Start recording
  Future<bool> startRecording() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isRecording) return false;

    try {
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentRecordingPath = '${directory.path}/drum_recording_$timestamp.aac';

      await _recorder.startRecorder(
        toFile: _currentRecordingPath,
        codec: Codec.aacADTS,
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
