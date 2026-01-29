import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/audio_service.dart';
import '../services/recording_service.dart';
import '../widgets/drum_pad_grid.dart';
import '../widgets/recording_controls.dart';

/// Main home screen with drum pad grid and recording controls
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();
  final RecordingService _recordingService = RecordingService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _audioService.initialize();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    _recordingService.dispose();
    super.dispose();
  }

  void _onPadTap(int index) {
    _audioService.playSound(index);
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 3,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppColors.textSecondary,
            ),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
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
              // Drum pad grid
              Expanded(
                child: _isInitialized
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: DrumPadGrid(onPadTap: _onPadTap),
                      )
                    : const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
              ),
              // Recording controls
              RecordingControls(
                recordingService: _recordingService,
                onRecordingStateChanged: () {
                  setState(() {});
                },
              ),
            ],
          ),
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
            InfoItem(
              icon: Icons.fiber_manual_record,
              text: 'Press record to capture your beats',
            ),
            InfoItem(icon: Icons.stop, text: 'Press stop when done'),
            InfoItem(icon: Icons.share, text: 'Share your creation!'),
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
