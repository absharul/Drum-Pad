import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/background_track.dart';
import '../services/background_music_service.dart';

/// Shows a modal bottom sheet for selecting and controlling background music
void showBackgroundMusicBottomSheet(
  BuildContext context,
  BackgroundMusicService musicService,
  VoidCallback onChanged,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => BackgroundMusicBottomSheet(
      musicService: musicService,
      onChanged: onChanged,
    ),
  );
}

/// Bottom sheet content for background music selection
class BackgroundMusicBottomSheet extends StatefulWidget {
  final BackgroundMusicService musicService;
  final VoidCallback onChanged;

  const BackgroundMusicBottomSheet({
    super.key,
    required this.musicService,
    required this.onChanged,
  });

  @override
  State<BackgroundMusicBottomSheet> createState() =>
      _BackgroundMusicBottomSheetState();
}

class _BackgroundMusicBottomSheetState
    extends State<BackgroundMusicBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.musicService.isPlaying
                          ? [AppColors.accent, const Color(0xFF4DF0FF)]
                          : [AppColors.cardBackground, AppColors.surface],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    widget.musicService.isPlaying
                        ? Icons.music_note
                        : Icons.library_music,
                    color: widget.musicService.isPlaying
                        ? Colors.white
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Background Beat',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.musicService.currentTrack?.title ??
                            'Select a beat to play',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // Play/Pause button
                if (widget.musicService.currentTrack != null)
                  IconButton(
                    icon: Icon(
                      widget.musicService.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: AppColors.accent,
                      size: 44,
                    ),
                    onPressed: () {
                      widget.musicService.togglePlayPause();
                      setState(() {});
                      widget.onChanged();
                    },
                  ),
              ],
            ),
          ),
          // Volume control
          _buildVolumeControl(),
          const Divider(color: AppColors.cardBackground, height: 1),
          // Track list
          _buildTrackList(),
          // No beat option
          _buildNoBeatOption(),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.volume_down,
            color: AppColors.textSecondary,
            size: 20,
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.accent,
                inactiveTrackColor: AppColors.cardBackground,
                thumbColor: AppColors.accent,
                overlayColor: AppColors.accent.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: widget.musicService.volume,
                onChanged: (value) {
                  widget.musicService.setVolume(value);
                  setState(() {});
                },
              ),
            ),
          ),
          const Icon(Icons.volume_up, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    final tracks = BackgroundTrack.allTracks;
    return Container(
      constraints: const BoxConstraints(maxHeight: 240),
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          final isCurrentTrack =
              widget.musicService.currentTrack?.id == track.id;
          final isPlaying = isCurrentTrack && widget.musicService.isPlaying;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCurrentTrack
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                track.icon,
                color: isCurrentTrack
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            title: Text(
              track.title,
              style: TextStyle(
                color: isCurrentTrack
                    ? AppColors.accent
                    : AppColors.textPrimary,
                fontWeight: isCurrentTrack
                    ? FontWeight.w600
                    : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            subtitle: Text(
              track.bpm,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            trailing: isCurrentTrack
                ? Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppColors.accent,
                    size: 28,
                  )
                : null,
            onTap: () async {
              if (isCurrentTrack) {
                await widget.musicService.togglePlayPause();
              } else {
                await widget.musicService.playTrack(track);
              }
              setState(() {});
              widget.onChanged();
            },
          );
        },
      ),
    );
  }

  Widget _buildNoBeatOption() {
    final hasTrack = widget.musicService.currentTrack != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          widget.musicService.stop();
          setState(() {});
          widget.onChanged();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: !hasTrack
                ? AppColors.accent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: !hasTrack
                  ? AppColors.accent
                  : AppColors.textSecondary.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_off,
                color: !hasTrack ? AppColors.accent : AppColors.textSecondary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Play Without Beat',
                style: TextStyle(
                  color: !hasTrack ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: !hasTrack ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
