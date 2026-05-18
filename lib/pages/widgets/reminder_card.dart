import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ReminderCard extends StatelessWidget {
  final double fontSize;
  final String message;

  const ReminderCard({
    super.key,
    required this.fontSize,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_active, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: fontSize - 1)),
          ),
        ],
      ),
    );
  }
}
