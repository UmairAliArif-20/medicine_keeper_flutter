import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({super.key, required this.fontSize});

  final double fontSize;

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  InputDecoration _buildFieldDecoration(IconData icon, String hintText) {
    return InputDecoration(
      prefixIcon: Icon(icon),
      hintText: hintText,
      hintStyle: TextStyle(fontSize: widget.fontSize - 1),
      filled: true,
      fillColor: AppColors.backgroundLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TextStyle baseTextStyle = TextStyle(fontSize: widget.fontSize);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 8),
              color: AppColors.cardShadow,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.lock, color: AppColors.primary, size: 34),
            ),
            const SizedBox(height: 12),
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: widget.fontSize + 8,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Sign in to continue',
              style: TextStyle(
                fontSize: widget.fontSize - 2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              style: baseTextStyle,
              decoration: _buildFieldDecoration(
                Icons.person_outline,
                'Username',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              style: baseTextStyle,
              decoration: _buildFieldDecoration(Icons.lock_outline, 'Password'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Login Successful',
                        style: TextStyle(fontSize: widget.fontSize),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: widget.fontSize),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
