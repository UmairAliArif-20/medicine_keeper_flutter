import 'package:flutter/material.dart';

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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.notifications_active, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: fontSize - 1, color: scheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
