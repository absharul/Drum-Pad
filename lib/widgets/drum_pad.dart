import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// A single drum pad with beautiful gradient and tap animations
class DrumPad extends StatefulWidget {
  final int index;
  final VoidCallback onTap;
  final String? label;

  const DrumPad({
    super.key,
    required this.index,
    required this.onTap,
    this.label,
  });

  @override
  State<DrumPad> createState() => _DrumPadState();
}

class _DrumPadState extends State<DrumPad> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
    HapticFeedback.mediumImpact();
    widget.onTap();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: AppColors.getPadGradient(widget.index),
              boxShadow: [
                // Base shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                // Glow effect on tap
                BoxShadow(
                  color: AppColors.getPadGlowColor(
                    widget.index,
                  ).withOpacity(_glowAnimation.value * 0.8),
                  blurRadius: 30 * _glowAnimation.value,
                  spreadRadius: 5 * _glowAnimation.value,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTapDown: _onTapDown,
                onTapUp: _onTapUp,
                onTapCancel: _onTapCancel,
                borderRadius: BorderRadius.circular(20),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getPadIcon(widget.index),
                          size: 36,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        if (widget.label != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.label!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getPadIcon(int index) {
    const icons = [
      Icons.music_note, // Kick
      Icons.album, // Snare
      Icons.audiotrack, // Hi-Hat
      Icons.surround_sound, // Clap
      Icons.graphic_eq, // Tom
      Icons.equalizer, // Cymbal
      Icons.vibration, // Percussion
      Icons.waves, // Bass
      Icons.spatial_audio, // FX
      Icons.piano, // Synth
      Icons.queue_music, // Loop
      Icons.multitrack_audio, // Mix
    ];
    return icons[index % icons.length];
  }
}
