import 'package:flutter/material.dart';
import '../models/sound_pack.dart';
import '../theme/app_colors.dart';

/// Horizontal scrollable selector for sound packs
class SoundPackSelector extends StatelessWidget {
  final SoundPack selectedPack;
  final ValueChanged<SoundPack> onPackSelected;

  const SoundPackSelector({
    super.key,
    required this.selectedPack,
    required this.onPackSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: SoundPack.allPacks.length,
        itemBuilder: (context, index) {
          final pack = SoundPack.allPacks[index];
          final isSelected = pack.id == selectedPack.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: GestureDetector(
              onTap: () => onPackSelected(pack),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: pack.gradientColors,
                        )
                      : null,
                  color: isSelected ? null : AppColors.cardBackground,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: pack.gradientColors[0].withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      pack.icon,
                      size: 28,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pack.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
