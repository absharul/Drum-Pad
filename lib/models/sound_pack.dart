import 'package:flutter/material.dart';

/// Represents a sound pack with a collection of drum sounds
class SoundPack {
  final String id;
  final String name;
  final IconData icon;
  final List<Color> gradientColors;
  final List<String> soundFiles;

  const SoundPack({
    required this.id,
    required this.name,
    required this.icon,
    required this.gradientColors,
    required this.soundFiles,
  });

  /// Default Hip Hop sound pack
  static const SoundPack hipHop = SoundPack(
    id: 'hip_hop',
    name: 'Hip Hop',
    icon: Icons.headphones,
    gradientColors: [Color(0xFFFF006E), Color(0xFFFF4D94)],
    soundFiles: [
      'audio/d1.mp3',
      'audio/d2.wav',
      'audio/d3.wav',
      'audio/d4.wav',
      'audio/d5.wav',
      'audio/d6.wav',
      'audio/d7.wav',
      'audio/d8.wav',
      'audio/d9.wav',
      'audio/d1.mp3',
      'audio/d2.wav',
      'audio/d3.wav',
    ],
  );

  /// EDM sound pack
  static const SoundPack edm = SoundPack(
    id: 'edm',
    name: 'EDM',
    icon: Icons.electric_bolt,
    gradientColors: [Color(0xFF00E5FF), Color(0xFF4DF0FF)],
    soundFiles: [
      'audio/d3.wav',
      'audio/d4.wav',
      'audio/d5.wav',
      'audio/d6.wav',
      'audio/d7.wav',
      'audio/d8.wav',
      'audio/d9.wav',
      'audio/d1.mp3',
      'audio/d2.wav',
      'audio/d3.wav',
      'audio/d4.wav',
      'audio/d5.wav',
    ],
  );

  /// 808 Bass pack
  static const SoundPack bass808 = SoundPack(
    id: '808_bass',
    name: '808 Bass',
    icon: Icons.speaker,
    gradientColors: [Color(0xFF8B5CF6), Color(0xFFAB8BFF)],
    soundFiles: [
      'audio/d5.wav',
      'audio/d6.wav',
      'audio/d7.wav',
      'audio/d8.wav',
      'audio/d9.wav',
      'audio/d1.mp3',
      'audio/d2.wav',
      'audio/d3.wav',
      'audio/d4.wav',
      'audio/d5.wav',
      'audio/d6.wav',
      'audio/d7.wav',
    ],
  );

  /// Acoustic drum kit
  static const SoundPack acoustic = SoundPack(
    id: 'acoustic',
    name: 'Acoustic',
    icon: Icons.album,
    gradientColors: [Color(0xFFFFBE0B), Color(0xFFFFD54F)],
    soundFiles: [
      'audio/d7.wav',
      'audio/d8.wav',
      'audio/d9.wav',
      'audio/d1.mp3',
      'audio/d2.wav',
      'audio/d3.wav',
      'audio/d4.wav',
      'audio/d5.wav',
      'audio/d6.wav',
      'audio/d7.wav',
      'audio/d8.wav',
      'audio/d9.wav',
    ],
  );

  /// All available sound packs
  static const List<SoundPack> allPacks = [hipHop, edm, bass808, acoustic];

  /// Get sound pack by ID
  static SoundPack getById(String id) {
    return allPacks.firstWhere((pack) => pack.id == id, orElse: () => hipHop);
  }
}
