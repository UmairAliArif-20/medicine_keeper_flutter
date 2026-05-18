import 'dart:io';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MedicineFormImageCard extends StatelessWidget {
  const MedicineFormImageCard({
    super.key,
    required this.fontSize,
    required this.imagePath,
    required this.onSwipeUp,
    required this.onSwipeDown,
  });

  final double fontSize;
  final String? imagePath;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    TextStyle titleStyle = TextStyle(
      fontSize: fontSize + 4,
      fontWeight: FontWeight.bold,
      color: scheme.onSurface,
    );

    TextStyle helperStyle = TextStyle(
      fontSize: fontSize - 1,
      color: scheme.onSurfaceVariant,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 16,
            offset: Offset(0, 6),
            color: AppColors.cardShadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Medicine photo', style: titleStyle),
          const SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: (details) {
              double? velocity = details.primaryVelocity;
              if (velocity == null) {
                return;
              }

              if (velocity < 0) {
                onSwipeUp();
              } else if (velocity > 0) {
                onSwipeDown();
              }
            },
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: imagePath == null || imagePath!.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image, size: 44, color: scheme.primary),
                        const SizedBox(height: 10),
                        Text('Swipe up to click picture', style: helperStyle),
                        const SizedBox(height: 4),
                        Text(
                          'Swipe down to select from gallery',
                          style: helperStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
