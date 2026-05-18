import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MedicineFormFieldsCard extends StatelessWidget {
  const MedicineFormFieldsCard({
    super.key,
    required this.fontSize,
    required this.nameController,
    required this.selectedTime,
    required this.onPickTime,
  });

  final double fontSize;
  final TextEditingController nameController;
  final TimeOfDay? selectedTime;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    String timeLabel = 'Choose time';
    if (selectedTime != null) {
      timeLabel = 'Time: ${selectedTime!.format(context)}';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Text(
            'Details',
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nameController,
            style: TextStyle(fontSize: fontSize),
            decoration: InputDecoration(
              labelText: 'Medicine name',
              filled: true,
              fillColor: AppColors.backgroundLight,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onPickTime,
              icon: const Icon(Icons.access_time),
              label: Text(timeLabel),
            ),
          ),
        ],
      ),
    );
  }
}
