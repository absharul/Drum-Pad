import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recording.dart';
import '../services/recordings_storage.dart';
import '../theme/app_colors.dart';

/// Screen displaying saved recordings with playback and management options
class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  final RecordingsStorage _storage = RecordingsStorage();
  final AudioPlayer _player = AudioPlayer();
  List<Recording> _recordings = [];
  String? _playingId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecordings();

    _player.onPlayerComplete.listen((_) {
      setState(() {
        _playingId = null;
      });
    });
  }

  Future<void> _loadRecordings() async {
    final recordings = await _storage.getRecordings();
    setState(() {
      _recordings = recordings;
      _isLoading = false;
    });
  }

  Future<void> _playRecording(Recording recording) async {
    if (_playingId == recording.id) {
      await _player.stop();
      setState(() {
        _playingId = null;
      });
    } else {
      await _player.stop();
      await _player.play(DeviceFileSource(recording.path));
      setState(() {
        _playingId = recording.id;
      });
    }
  }

  Future<void> _shareRecording(Recording recording) async {
    await Share.shareXFiles(
      [XFile(recording.path)],
      text: 'Check out my drum beat: ${recording.name} 🥁',
      subject: 'Drum Pad Recording',
    );
  }

  Future<void> _deleteRecording(Recording recording) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Recording?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${recording.name}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.recordingRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (_playingId == recording.id) {
        await _player.stop();
        _playingId = null;
      }
      await _storage.deleteRecording(recording.id);
      await _loadRecordings();
    }
  }

  Future<void> _renameRecording(Recording recording) async {
    final controller = TextEditingController(text: recording.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Rename Recording',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != recording.name) {
      await _storage.renameRecording(recording.id, newName);
      await _loadRecordings();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF006E), Color(0xFF00E5FF)],
          ).createShader(bounds),
          child: const Text(
            '💾 MY BEATS',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                )
              : _recordings.isEmpty
              ? _buildEmptyState()
              : _buildRecordingsList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBackground,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Icon(
              Icons.music_off,
              size: 50,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Recordings Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start making beats and save them here!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Beat',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recordings.length,
      itemBuilder: (context, index) {
        final recording = _recordings[index];
        final isPlaying = _playingId == recording.id;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? AppColors.accent.withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: isPlaying ? 2 : 1,
            ),
            boxShadow: isPlaying
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.2),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: GestureDetector(
              onTap: () => _playRecording(recording),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isPlaying
                      ? const LinearGradient(
                          colors: [AppColors.accent, Color(0xFF4DD0E1)],
                        )
                      : null,
                  color: isPlaying ? null : AppColors.surface,
                ),
                child: Icon(
                  isPlaying ? Icons.stop : Icons.play_arrow,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            title: Text(
              recording.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Row(
              children: [
                Icon(
                  Icons.timer,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  recording.formattedDuration,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.calendar_today,
                  size: 14,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  recording.formattedDate,
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: AppColors.textSecondary.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: () => _renameRecording(recording),
                ),
                IconButton(
                  icon: Icon(
                    Icons.share,
                    color: AppColors.accent.withOpacity(0.8),
                    size: 20,
                  ),
                  onPressed: () => _shareRecording(recording),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.recordingRed.withOpacity(0.8),
                    size: 20,
                  ),
                  onPressed: () => _deleteRecording(recording),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
