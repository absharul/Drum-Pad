import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/background_track.dart';
import '../services/background_music_service.dart';

/// Widget for selecting and playing background beats
class BackgroundMusicPlayer extends StatefulWidget {
  final BackgroundMusicService musicService;

  const BackgroundMusicPlayer({super.key, required this.musicService});

  @override
  State<BackgroundMusicPlayer> createState() => _BackgroundMusicPlayerState();
}

class _BackgroundMusicPlayerState extends State<BackgroundMusicPlayer>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - always visible
          _buildHeader(),
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: _buildExpandedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final currentTrack = widget.musicService.currentTrack;
    final isPlaying = widget.musicService.isPlaying;

    return InkWell(
      onTap: _toggleExpand,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Music icon with animation
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPlaying
                      ? [AppColors.accent, const Color(0xFF4DF0FF)]
                      : [AppColors.cardBackground, AppColors.surface],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isPlaying ? Icons.music_note : Icons.library_music,
                color: isPlaying ? Colors.white : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTrack?.title ?? 'Background Beat',
                    style: TextStyle(
                      color: currentTrack != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    currentTrack != null
                        ? currentTrack.bpm
                        : 'Tap to select a beat',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Play/Pause button
            if (currentTrack != null)
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: AppColors.accent,
                  size: 36,
                ),
                onPressed: () {
                  widget.musicService.togglePlayPause();
                  setState(() {});
                },
              ),
            // Stop button
            if (currentTrack != null)
              IconButton(
                icon: const Icon(
                  Icons.stop_circle,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
                onPressed: () {
                  widget.musicService.stop();
                  setState(() {});
                },
              ),
            // Expand/collapse icon
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Column(
      children: [
        // Volume control
        _buildVolumeControl(),
        // Track list
        _buildTrackList(),
        // No beat option
        _buildNoBeatOption(),
      ],
    );
  }

  Widget _buildVolumeControl() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.volume_down, color: AppColors.textSecondary, size: 20),
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
          Icon(Icons.volume_up, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    final tracks = BackgroundTrack.allTracks;
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          final isCurrentTrack =
              widget.musicService.currentTrack?.id == track.id;
          final isPlaying = isCurrentTrack && widget.musicService.isPlaying;

          return ListTile(
            dense: true,
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCurrentTrack
                    ? AppColors.accent.withOpacity(0.2)
                    : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                track.icon,
                color: isCurrentTrack
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 18,
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
                fontSize: 13,
              ),
            ),
            subtitle: Text(
              track.bpm,
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
            trailing: isCurrentTrack
                ? Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: AppColors.accent,
                  )
                : null,
            onTap: () async {
              if (isCurrentTrack) {
                await widget.musicService.togglePlayPause();
              } else {
                await widget.musicService.playTrack(track);
              }
              setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _buildNoBeatOption() {
    final hasTrack = widget.musicService.currentTrack != null;

    return Container(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () {
          widget.musicService.stop();
          setState(() {});
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: !hasTrack
                ? AppColors.accent.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Play Without Beat',
                style: TextStyle(
                  color: !hasTrack ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: !hasTrack ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
