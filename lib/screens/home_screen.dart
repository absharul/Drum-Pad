import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/audio_service.dart';
import '../services/recording_service.dart';
import '../services/recordings_storage.dart';
import '../services/background_music_service.dart';
import '../models/sound_pack.dart';
import '../models/recording.dart';
import '../models/settings_model.dart';
import '../widgets/drum_pad_grid.dart';
import '../widgets/recording_controls.dart';
import '../widgets/sound_pack_selector.dart';
import '../widgets/waveform_visualizer.dart';
import '../widgets/bpm_control.dart';
import '../widgets/background_music_bottom_sheet.dart';
import 'recordings_screen.dart';
import 'settings_screen.dart';

/// Main home screen with drum pad grid, recording controls, and enhanced features
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  final RecordingService _recordingService = RecordingService();
  final RecordingsStorage _recordingsStorage = RecordingsStorage();
  final BackgroundMusicService _backgroundMusicService =
      BackgroundMusicService();
  final AppSettings _appSettings = AppSettings();
  bool _isInitialized = false;
  bool _showBpmControl = false;
  bool _isPlayingSound = false;
  late AnimationController _waveformController;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Future<void> _initializeServices() async {
    await _audioService.initialize();
    await _backgroundMusicService.initialize();
    await _appSettings.initialize();
    // Sync recording service with saved settings
    _recordingService.setRecordingSource(_appSettings.recordingSource);
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    _recordingService.dispose();
    _backgroundMusicService.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  void _onPadTap(int index) {
    _audioService.playSound(index);
    // Trigger waveform animation
    setState(() {
      _isPlayingSound = true;
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isPlayingSound = false;
        });
      }
    });
  }

  void _onSoundPackChanged(SoundPack pack) {
    _audioService.switchSoundPack(pack);
    setState(() {});
  }

  Future<void> _saveRecording(String? path, Duration duration) async {
    if (path == null) return;

    final recording = Recording(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      path: path,
      name:
          'Beat ${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      duration: duration,
      createdAt: DateTime.now(),
    );

    await _recordingsStorage.saveRecording(recording);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF006E), Color(0xFF00E5FF), Color(0xFF8B5CF6)],
          ).createShader(bounds),
          child: const Text(
            '🥁 DRUM PAD',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          // BPM toggle button
          IconButton(
            icon: Icon(
              Icons.speed,
              color: _showBpmControl
                  ? AppColors.accent
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              setState(() {
                _showBpmControl = !_showBpmControl;
              });
            },
            tooltip: 'Metronome',
          ),
          // Recordings button
          IconButton(
            icon: const Icon(
              Icons.library_music,
              color: AppColors.textSecondary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RecordingsScreen(),
                ),
              );
            },
            tooltip: 'My Beats',
          ),
          // Info button
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
            ),
            onPressed: () => _showInfoDialog(context),
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(settings: _appSettings),
                ),
              ).then((_) {
                // Sync recording service when returning from settings
                _recordingService.setRecordingSource(
                  _appSettings.recordingSource,
                );
              });
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Sound Pack Selector
              SoundPackSelector(
                selectedPack: _audioService.currentPack,
                onPackSelected: _onSoundPackChanged,
              ),

              // Status indicator
              if (_recordingService.isRecording)
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.recordingRed.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.recordingRed.withOpacity(0.5),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        color: AppColors.recordingRed,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Recording in progress...',
                        style: TextStyle(
                          color: AppColors.recordingRed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // BPM Control (expandable)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _showBpmControl
                    ? const BpmControl()
                    : const SizedBox.shrink(),
              ),

              // Compact background music indicator
              _buildMusicIndicator(),

              // Drum pad grid
              Expanded(
                child: _isInitialized
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: DrumPadGrid(onPadTap: _onPadTap),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
              ),

              // Waveform Visualizer
              WaveformVisualizer(
                isActive: _isPlayingSound || _recordingService.isRecording,
                activeColor: _recordingService.isRecording
                    ? AppColors.recordingRed
                    : AppColors.accent,
              ),

              // Recording controls
              RecordingControls(
                recordingService: _recordingService,
                onRecordingStateChanged: () {
                  setState(() {});
                },
                onRecordingSaved: _saveRecording,
              ),
            ],
          ),
        ),
      ),
      // Floating action button for background music
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showBackgroundMusicBottomSheet(
            context,
            _backgroundMusicService,
            () => setState(() {}),
          );
        },
        backgroundColor: _backgroundMusicService.isPlaying
            ? AppColors.accent
            : AppColors.surface,
        child: Icon(
          _backgroundMusicService.isPlaying
              ? Icons.music_note
              : Icons.library_music,
          color: _backgroundMusicService.isPlaying
              ? Colors.white
              : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMusicIndicator() {
    final currentTrack = _backgroundMusicService.currentTrack;
    final isPlaying = _backgroundMusicService.isPlaying;

    if (currentTrack == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        showBackgroundMusicBottomSheet(
          context,
          _backgroundMusicService,
          () => setState(() {}),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPlaying
                ? AppColors.accent.withOpacity(0.5)
                : AppColors.cardBackground,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPlaying ? Icons.music_note : Icons.music_off,
              color: isPlaying ? AppColors.accent : AppColors.textSecondary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              currentTrack.title,
              style: TextStyle(
                color: isPlaying ? AppColors.accent : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                _backgroundMusicService.togglePlayPause();
                setState(() {});
              },
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.accent,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🥁 ', style: TextStyle(fontSize: 28)),
            Text('Drum Pad', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to use:',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 12),
            InfoItem(icon: Icons.touch_app, text: 'Tap pads to play sounds'),
            InfoItem(icon: Icons.music_note, text: 'Switch sound packs at top'),
            InfoItem(icon: Icons.speed, text: 'Use metronome for timing'),
            InfoItem(
              icon: Icons.fiber_manual_record,
              text: 'Record your beats',
            ),
            InfoItem(icon: Icons.library_music, text: 'Access saved beats'),
            InfoItem(icon: Icons.share, text: 'Share your creations!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Got it!',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
