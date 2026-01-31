import 'package:flutter/material.dart';

/// Represents a background beat track
class BackgroundTrack {
  final String id;
  final String title;
  final String bpm;
  final String assetPath;
  final IconData icon;

  const BackgroundTrack({
    required this.id,
    required this.title,
    required this.bpm,
    required this.assetPath,
    this.icon = Icons.music_note,
  });

  /// List of available local beat tracks
  static const List<BackgroundTrack> allTracks = [
    BackgroundTrack(
      id: 'beat_1',
      title: 'Drums Beat',
      bpm: '120 BPM',
      assetPath: 'beats/drums-beat-302606.mp3',
      icon: Icons.album,
    ),
    BackgroundTrack(
      id: 'beat_2',
      title: 'Beat Drums 4/4',
      bpm: '120 BPM',
      assetPath: 'beats/beat-drums-4_4_120bpm-9sek-275095.mp3',
      icon: Icons.audiotrack,
    ),
    BackgroundTrack(
      id: 'beat_3',
      title: 'Drums Loop 1',
      bpm: '75 BPM',
      assetPath: 'beats/drums-loop-75bpm-2-455451.mp3',
      icon: Icons.loop,
    ),
    BackgroundTrack(
      id: 'beat_4',
      title: 'Drums Loop 2',
      bpm: '75 BPM',
      assetPath: 'beats/drums-loop-75bpm-3-455453.mp3',
      icon: Icons.loop,
    ),
    BackgroundTrack(
      id: 'beat_5',
      title: 'Drums Loop 3',
      bpm: '80 BPM',
      assetPath: 'beats/drums-loop-80bpm-2-455454.mp3',
      icon: Icons.loop,
    ),
    BackgroundTrack(
      id: 'beat_6',
      title: 'Inspiration Drums',
      bpm: '110 BPM',
      assetPath: 'beats/inspiration-drums-152644.mp3',
      icon: Icons.lightbulb,
    ),
  ];
}
