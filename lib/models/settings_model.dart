import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recording audio source options
enum RecordingSource {
  micOnly, // Record only from microphone
  deviceAudio, // Record only device/internal audio (Android 10+)
  mixed, // Record both mic and device audio (Android 10+)
}

extension RecordingSourceExtension on RecordingSource {
  String get displayName {
    switch (this) {
      case RecordingSource.micOnly:
        return 'Microphone Only';
      case RecordingSource.deviceAudio:
        return 'Device Audio Only';
      case RecordingSource.mixed:
        return 'Mic + Device Audio';
    }
  }

  String get description {
    switch (this) {
      case RecordingSource.micOnly:
        return 'Records audio from the microphone';
      case RecordingSource.deviceAudio:
        return 'Records internal audio from the app (Android 10+)';
      case RecordingSource.mixed:
        return 'Records both microphone and app audio (Android 10+)';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordingSource.micOnly:
        return Icons.mic;
      case RecordingSource.deviceAudio:
        return Icons.speaker;
      case RecordingSource.mixed:
        return Icons.headset_mic;
    }
  }
}

/// App settings storage and management
class AppSettings {
  static const String _recordingSourceKey = 'recording_source';

  SharedPreferences? _prefs;
  RecordingSource _recordingSource = RecordingSource.micOnly;

  /// Get the current recording source
  RecordingSource get recordingSource => _recordingSource;

  /// Initialize settings from storage
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    final sourceIndex = _prefs?.getInt(_recordingSourceKey) ?? 0;
    _recordingSource = RecordingSource
        .values[sourceIndex.clamp(0, RecordingSource.values.length - 1)];
  }

  /// Set the recording source
  Future<void> setRecordingSource(RecordingSource source) async {
    _recordingSource = source;
    await _prefs?.setInt(_recordingSourceKey, source.index);
  }
}
