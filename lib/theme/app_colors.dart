import 'package:flutter/material.dart';

/// App color palette with vibrant neon colors for the drum pads
class AppColors {
  // Background colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color cardBackground = Color(0xFF2A2A2A);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);

  // Recording indicator
  static const Color recordingRed = Color(0xFFFF4444);
  static const Color recordingGlow = Color(0x40FF4444);

  // Accent colors
  static const Color accent = Color(0xFF00E5FF);
  static const Color accentGlow = Color(0x4000E5FF);

  // Drum pad gradient colors - vibrant neon palette
  static const List<List<Color>> padGradients = [
    // Row 1
    [Color(0xFFFF006E), Color(0xFFFF4D94)], // Neon Pink
    [Color(0xFF00E5FF), Color(0xFF4DF0FF)], // Cyan
    [Color(0xFF8B5CF6), Color(0xFFAB8BFF)], // Purple
    // Row 2
    [Color(0xFFFFBE0B), Color(0xFFFFD54F)], // Yellow/Gold
    [Color(0xFFFF5722), Color(0xFFFF8A65)], // Orange
    [Color(0xFF00FF87), Color(0xFF4DFFAB)], // Neon Green
    // Row 3
    [Color(0xFFE040FB), Color(0xFFEA80FC)], // Magenta
    [Color(0xFF00B8D4), Color(0xFF4DD0E1)], // Teal
    [Color(0xFFCDDC39), Color(0xFFDCE775)], // Lime
  ];

  // Get gradient for a specific pad (0-8)
  static LinearGradient getPadGradient(int index) {
    final colors = padGradients[index % padGradients.length];
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  // Get glow color for a specific pad
  static Color getPadGlowColor(int index) {
    return padGradients[index % padGradients.length][0].withOpacity(0.5);
  }

  // App bar gradient
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  // Background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f0f23)],
  );
}
