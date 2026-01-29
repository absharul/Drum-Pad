import 'package:flutter/material.dart';
import 'drum_pad.dart';

/// A 3x3 grid of drum pads
class DrumPadGrid extends StatelessWidget {
  final Function(int) onPadTap;

  const DrumPadGrid({super.key, required this.onPadTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate grid size based on available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final gridSize = availableWidth < availableHeight
            ? availableWidth
            : availableHeight;

        return Center(
          child: SizedBox(
            width: gridSize,
            height: gridSize,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                return DrumPad(index: index, onTap: () => onPadTap(index));
              },
            ),
          ),
        );
      },
    );
  }
}
