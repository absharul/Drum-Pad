import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/recording_service.dart';

/// Recording controls widget with record, stop, and share buttons
class RecordingControls extends StatefulWidget {
  final RecordingService recordingService;
  final VoidCallback? onRecordingStateChanged;
  final void Function(String? path, Duration duration)? onRecordingSaved;

  const RecordingControls({
    super.key,
    required this.recordingService,
    this.onRecordingStateChanged,
    this.onRecordingSaved,
  });

  @override
  State<RecordingControls> createState() => _RecordingControlsState();
}

class _RecordingControlsState extends State<RecordingControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<Duration>? _durationSubscription;
  Duration _currentDuration = Duration.zero;
  bool _hasRecording = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _durationSubscription = widget.recordingService.durationStream.listen((
      duration,
    ) {
      setState(() {
        _currentDuration = duration;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _durationSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _toggleRecording() async {
    if (widget.recordingService.isRecording) {
      final path = await widget.recordingService.stopRecording();
      final duration = _currentDuration;
      _pulseController.stop();
      _pulseController.reset();
      setState(() {
        _hasRecording = true;
      });
      // Save the recording
      widget.onRecordingSaved?.call(path, duration);
    } else {
      final success = await widget.recordingService.startRecording();
      if (success) {
        _pulseController.repeat(reverse: true);
        setState(() {
          _currentDuration = Duration.zero;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not start recording. Please grant microphone permission.',
              ),
              backgroundColor: AppColors.recordingRed,
            ),
          );
        }
      }
    }
    widget.onRecordingStateChanged?.call();
  }

  Future<void> _shareRecording() async {
    final success = await widget.recordingService.shareRecording();
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not share recording.'),
          backgroundColor: AppColors.recordingRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = widget.recordingService.isRecording;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Duration display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: isRecording
                    ? AppColors.recordingRed.withOpacity(0.2)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRecording) ...[
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.recordingRed,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.recordingRed.withOpacity(
                                  _pulseAnimation.value - 0.8,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    isRecording ? 'REC' : 'READY',
                    style: TextStyle(
                      color: isRecording
                          ? AppColors.recordingRed
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _formatDuration(_currentDuration),
                    style: TextStyle(
                      color: isRecording
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Record/Stop button
                GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: isRecording
                              ? null
                              : const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.recordingRed,
                                    Color(0xFFFF6B6B),
                                  ],
                                ),
                          color: isRecording ? AppColors.surface : null,
                          border: Border.all(
                            color: isRecording
                                ? AppColors.recordingRed
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isRecording
                                          ? AppColors.recordingRed
                                          : const Color(0xFFFF4444))
                                      .withOpacity(
                                        isRecording
                                            ? (_pulseAnimation.value - 0.8) *
                                                  0.5
                                            : 0.4,
                                      ),
                              blurRadius: 20,
                              spreadRadius: isRecording ? 5 : 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: isRecording
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.recordingRed,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                )
                              : const Icon(
                                  Icons.fiber_manual_record,
                                  color: Colors.white,
                                  size: 32,
                                ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 32),
                // Share button
                GestureDetector(
                  onTap: _hasRecording && !isRecording ? _shareRecording : null,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _hasRecording && !isRecording
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.accent, Color(0xFF4DD0E1)],
                            )
                          : null,
                      color: _hasRecording && !isRecording
                          ? null
                          : AppColors.cardBackground,
                      boxShadow: _hasRecording && !isRecording
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 15,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.share_rounded,
                      color: _hasRecording && !isRecording
                          ? Colors.white
                          : AppColors.textSecondary.withOpacity(0.5),
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Hint text
            Text(
              isRecording
                  ? 'Tap the square to stop recording'
                  : _hasRecording
                  ? 'Tap share to send your beat!'
                  : 'Tap the red button to start recording',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
