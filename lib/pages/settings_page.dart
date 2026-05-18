import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// --- PAGE 4: SETTINGS ---
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.fontSize,
    required this.onChanged,
  });

  final double fontSize;
  final ValueChanged<double> onChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final TextStyle titleStyle = TextStyle(
      fontSize: widget.fontSize + 8,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );
    final TextStyle helperStyle = TextStyle(
      fontSize: widget.fontSize - 1,
      color: AppColors.textSecondary,
    );

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: titleStyle),
          const SizedBox(height: 12),
          Text('Customize your reading experience.', style: helperStyle),
          const SizedBox(height: 18),
          // Settings card.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
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
                Text(
                  'Font Size',
                  style: TextStyle(
                    fontSize: widget.fontSize + 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                DropdownMenu<double>(
                  initialSelection: widget.fontSize,
                  width: 220,
                  label: const Text("Choose size"),
                  onSelected: (double? value) {
                    if (value != null) {
                      widget.onChanged(value);
                    }
                  },
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 16.0, label: "Small"),
                    DropdownMenuEntry(value: 24.0, label: "Medium"),
                    DropdownMenuEntry(value: 32.0, label: "Large"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
