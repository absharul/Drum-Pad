import 'package:flutter/material.dart';
import 'drum_pad.dart';

/// A 4x3 grid of drum pads with labels
class DrumPadGrid extends StatelessWidget {
  final Function(int) onPadTap;

  // Pad labels for different drum sounds
  static const List<String> padLabels = [
    'KICK',
    'SNARE',
    'HI-HAT',
    'CYMBAL',
    'TOM',
    'CRASH',
    'RIDE 1',
    'RIDE 2',
    'E-CRASH',
    'E-RIDE',
    'LONG RIDE',
    'FX',
  ];

  const DrumPadGrid({super.key, required this.onPadTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate grid size based on available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Calculate optimal size for 4x3 grid
        final cellWidth = availableWidth / 3;
        final cellHeight = availableHeight / 4;
        final aspectRatio = cellWidth / cellHeight;

        return Center(
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 11,
              childAspectRatio: aspectRatio.clamp(0.8, 1.5),
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              return DrumPad(
                index: index,
                onTap: () => onPadTap(index),
                label: padLabels[index],
              );
            },
          ),
        );
      },
    );
  }
}
