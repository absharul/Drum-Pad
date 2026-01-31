import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated waveform visualizer that responds to audio playback
class WaveformVisualizer extends StatefulWidget {
  final bool isActive;
  final Color? activeColor;

  const WaveformVisualizer({
    super.key,
    this.isActive = false,
    this.activeColor,
  });

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final int _barCount = 32;
  List<double> _barHeights = [];
  List<double> _targetHeights = [];

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(_barCount, (_) => 0.2);
    _targetHeights = List.generate(_barCount, (_) => 0.2);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )..addListener(_updateBars);

    if (widget.isActive) {
      _controller.repeat();
    }
  }

  void _updateBars() {
    if (widget.isActive) {
      setState(() {
        for (int i = 0; i < _barCount; i++) {
          // Smoothly animate towards target heights
          _barHeights[i] =
              _barHeights[i] + (_targetHeights[i] - _barHeights[i]) * 0.3;
        }
        // Generate new random targets periodically
        if (_controller.value < 0.1) {
          _targetHeights = List.generate(_barCount, (index) {
            // Create a wave-like pattern
            final centerFactor =
                1 - ((index - _barCount / 2).abs() / (_barCount / 2)) * 0.3;
            return (_random.nextDouble() * 0.7 + 0.3) * centerFactor;
          });
        }
      });
    } else {
      setState(() {
        for (int i = 0; i < _barCount; i++) {
          _barHeights[i] = _barHeights[i] + (0.15 - _barHeights[i]) * 0.1;
        }
      });
    }
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isActive && _controller.isAnimating) {
      // Keep animating to smoothly decay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!widget.isActive && mounted) {
          _controller.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.accent;

    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CustomPaint(
          size: const Size(double.infinity, 32),
          painter: _WaveformPainter(
            barHeights: _barHeights,
            activeColor: activeColor,
            isActive: widget.isActive,
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final Color activeColor;
  final bool isActive;

  _WaveformPainter({
    required this.barHeights,
    required this.activeColor,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / barHeights.length;
    final padding = barWidth * 0.2;

    for (int i = 0; i < barHeights.length; i++) {
      final barHeight = barHeights[i] * size.height;
      final x = i * barWidth + padding / 2;

      // Create gradient for each bar
      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: isActive
            ? [
                activeColor.withOpacity(0.6),
                activeColor,
                activeColor.withOpacity(0.8),
              ]
            : [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.3)],
      );

      final rect = Rect.fromLTWH(
        x,
        (size.height - barHeight) / 2,
        barWidth - padding,
        barHeight,
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.fill;

      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rrect, paint);

      // Add glow effect when active
      if (isActive && barHeights[i] > 0.6) {
        final glowPaint = Paint()
          ..color = activeColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawRRect(rrect, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return true;
  }
}
