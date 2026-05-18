import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class MedicineFormActionCard extends StatelessWidget {
  const MedicineFormActionCard({
    super.key,
    required this.fontSize,
    required this.buttonText,
    required this.onPressed,
  });

  final double fontSize;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(buttonText, style: TextStyle(fontSize: fontSize)),
        ),
      ),
    );
  }
}
