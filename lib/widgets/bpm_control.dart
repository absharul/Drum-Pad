import 'dart:async';
import 'package:flutter/material.dart';
import '../services/metronome_service.dart';
import '../theme/app_colors.dart';

/// BPM control widget with slider, tap tempo, and beat indicator
class BpmControl extends StatefulWidget {
  const BpmControl({super.key});

  @override
  State<BpmControl> createState() => _BpmControlState();
}

class _BpmControlState extends State<BpmControl>
    with SingleTickerProviderStateMixin {
  final MetronomeService _metronome = MetronomeService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<int>? _beatSubscription;
  int _currentBeat = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMetronome();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  Future<void> _initializeMetronome() async {
    await _metronome.initialize();
    _beatSubscription = _metronome.beatStream.listen((beat) {
      setState(() {
        _currentBeat = beat;
      });
      if (beat > 0) {
        _pulseController.forward().then((_) => _pulseController.reverse());
      }
    });
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _beatSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Header row with BPM display and controls
          Row(
            children: [
              // BPM Display
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _metronome.isPlaying ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _metronome.isPlaying
                            ? AppColors.accent.withOpacity(0.2)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _metronome.isPlaying
                              ? AppColors.accent.withOpacity(0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_metronome.bpm}',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _metronome.isPlaying
                                  ? AppColors.accent
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'BPM',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Beat indicators
              Row(
                children: List.generate(4, (index) {
                  final beatNum = index + 1;
                  final isActive = _currentBeat == beatNum;
                  return Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? (beatNum == 1
                                ? AppColors.recordingRed
                                : AppColors.accent)
                          : AppColors.surface,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color:
                                    (beatNum == 1
                                            ? AppColors.recordingRed
                                            : AppColors.accent)
                                        .withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$beatNum',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // BPM Slider
          Row(
            children: [
              Text(
                '40',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.surface,
                    thumbColor: AppColors.accent,
                    overlayColor: AppColors.accent.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _metronome.bpm.toDouble(),
                    min: 40,
                    max: 240,
                    onChanged: (value) {
                      setState(() {
                        _metronome.setBpm(value.round());
                      });
                    },
                  ),
                ),
              ),
              Text(
                '240',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Play/Stop button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _metronome.toggle();
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _metronome.isPlaying
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.accent, Color(0xFF4DD0E1)],
                          ),
                    color: _metronome.isPlaying ? AppColors.surface : null,
                    border: _metronome.isPlaying
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Icon(
                    _metronome.isPlaying ? Icons.stop : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Tap tempo button
              GestureDetector(
                onTap: () {
                  _metronome.tapTempo();
                  setState(() {});
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      Text(
                        'TAP',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Sound toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _metronome.toggleSound();
                  });
                },
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surface,
                    border: Border.all(
                      color: _metronome.soundEnabled
                          ? AppColors.accent.withOpacity(0.5)
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Icon(
                    _metronome.soundEnabled
                        ? Icons.volume_up
                        : Icons.volume_off,
                    color: _metronome.soundEnabled
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
