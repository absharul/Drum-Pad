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
      'audio/kick-drum-acoustic-sample-455285.mp3',
      'audio/snare-drum-341273.mp3',
      'audio/hi-hat-hit-open-98747.mp3',
      'audio/cymbal-crash-412547.mp3',
      'audio/floor_tom-96475.mp3',
      'audio/tr909-crash-cymbal-241378.mp3',
      'audio/long-ride-cymbal-2-36337.mp3',
      'audio/long-ride-cymbal-94674.mp3',
      'audio/electronic-crash-3-47448.mp3',
      'audio/electronic-ride-1-100403.mp3',
      'audio/long-ride-cymbal-2-36337.mp3',
      'audio/bad-joke-drum-352439.mp3',
    ],
  );

  /// EDM sound pack
  static const SoundPack edm = SoundPack(
    id: 'edm',
    name: 'EDM',
    icon: Icons.electric_bolt,
    gradientColors: [Color(0xFF00E5FF), Color(0xFF4DF0FF)],
    soundFiles: [
      'audio/kick-drum-acoustic-sample-455285.mp3',
      'audio/snare-drum-341273.mp3',
      'audio/electronic-ride-1-100403.mp3',
      'audio/electronic-crash-3-47448.mp3',
      'audio/floor_tom-96475.mp3',
      'audio/tr909-crash-cymbal-241378.mp3',
      'audio/long-ride-cymbal-2-36337.mp3',
      'audio/long-ride-cymbal-94674.mp3',
      'audio/cymbal-crash-412547.mp3',
      'audio/hi-hat-hit-open-98747.mp3',
      'audio/bad-joke-drum-352439.mp3',
      'audio/electronic-crash-3-47448.mp3',
    ],
  );

  /// 808 Bass pack
  static const SoundPack bass808 = SoundPack(
    id: '808_bass',
    name: '808 Bass',
    icon: Icons.speaker,
    gradientColors: [Color(0xFF8B5CF6), Color(0xFFAB8BFF)],
    soundFiles: [
      'audio/kick-drum-acoustic-sample-455285.mp3',
      'audio/snare-drum-341273.mp3',
      'audio/hi-hat-hit-open-98747.mp3',
      'audio/tr909-crash-cymbal-241378.mp3',
      'audio/floor_tom-96475.mp3',
      'audio/electronic-crash-3-47448.mp3',
      'audio/electronic-ride-1-100403.mp3',
      'audio/long-ride-cymbal-94674.mp3',
      'audio/cymbal-crash-412547.mp3',
      'audio/long-ride-cymbal-2-36337.mp3',
      'audio/bad-joke-drum-352439.mp3',
      'audio/hi-hat-hit-open-98747.mp3',
    ],
  );

  /// Acoustic drum kit
  static const SoundPack acoustic = SoundPack(
    id: 'acoustic',
    name: 'Acoustic',
    icon: Icons.album,
    gradientColors: [Color(0xFFFFBE0B), Color(0xFFFFD54F)],
    soundFiles: [
      'audio/kick-drum-acoustic-sample-455285.mp3',
      'audio/snare-drum-341273.mp3',
      'audio/hi-hat-hit-open-98747.mp3',
      'audio/cymbal-crash-412547.mp3',
      'audio/floor_tom-96475.mp3',
      'audio/tr909-crash-cymbal-241378.mp3',
      'audio/long-ride-cymbal-2-36337.mp3',
      'audio/long-ride-cymbal-94674.mp3',
      'audio/electronic-crash-3-47448.mp3',
      'audio/electronic-ride-1-100403.mp3',
      'audio/bad-joke-drum-352439.mp3',
      'audio/cymbal-crash-412547.mp3',
    ],
  );

  /// All available sound packs
  static const List<SoundPack> allPacks = [hipHop, edm, bass808, acoustic];

  /// Get sound pack by ID
  static SoundPack getById(String id) {
    return allPacks.firstWhere((pack) => pack.id == id, orElse: () => hipHop);
  }
}
