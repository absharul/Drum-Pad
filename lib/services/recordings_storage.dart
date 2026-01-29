import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recording.dart';

/// Service for persisting and managing recordings
class RecordingsStorage {
  static const String _recordingsKey = 'drum_pad_recordings';

  /// Get all saved recordings
  Future<List<Recording>> getRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recordingsKey);

    if (jsonString == null) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      final recordings = jsonList
          .map((json) => Recording.fromJson(json as Map<String, dynamic>))
          .toList();

      // Filter out recordings whose files no longer exist
      final validRecordings = <Recording>[];
      for (final recording in recordings) {
        if (await File(recording.path).exists()) {
          validRecordings.add(recording);
        }
      }

      // Sort by date, newest first
      validRecordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return validRecordings;
    } catch (e) {
      return [];
    }
  }

  /// Save a new recording
  Future<void> saveRecording(Recording recording) async {
    final recordings = await getRecordings();
    recordings.insert(0, recording); // Add to beginning
    await _saveRecordings(recordings);
  }

  /// Delete a recording by ID
  Future<void> deleteRecording(String id) async {
    final recordings = await getRecordings();

    // Find and delete the file
    final recording = recordings.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Recording not found'),
    );

    final file = File(recording.path);
    if (await file.exists()) {
      await file.delete();
    }

    // Remove from list
    recordings.removeWhere((r) => r.id == id);
    await _saveRecordings(recordings);
  }

  /// Rename a recording
  Future<void> renameRecording(String id, String newName) async {
    final recordings = await getRecordings();
    final index = recordings.indexWhere((r) => r.id == id);

    if (index != -1) {
      recordings[index] = recordings[index].copyWith(name: newName);
      await _saveRecordings(recordings);
    }
  }

  /// Save recordings to SharedPreferences
  Future<void> _saveRecordings(List<Recording> recordings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = recordings.map((r) => r.toJson()).toList();
    await prefs.setString(_recordingsKey, jsonEncode(jsonList));
  }

  /// Clear all recordings
  Future<void> clearAll() async {
    final recordings = await getRecordings();

    // Delete all files
    for (final recording in recordings) {
      final file = File(recording.path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Clear storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordingsKey);
  }
}
