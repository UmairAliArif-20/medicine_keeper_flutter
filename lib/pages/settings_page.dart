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
  // Form key and controllers for password update fields
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() {
    if (_formKey.currentState!.validate()) {
      // Logic for changing password can go here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reset the inputs after submission
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    }
  }

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

    return SingleChildScrollView(
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

          const SizedBox(height: 24),

          // --- Password Security Section Added Below Your Container ---
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Security & Password',
                    style: TextStyle(
                      fontSize: widget.fontSize + 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Current Password Input Field
                  TextFormField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    style: TextStyle(fontSize: widget.fontSize),
                    decoration: const InputDecoration(
                      labelText: 'Current Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // New Password Input Field
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    style: TextStyle(fontSize: widget.fontSize),
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_reset_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'New password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Confirm New Password Input Field
                  TextFormField(
                    controller: _confirmNewPasswordController,
                    obscureText: true,
                    style: TextStyle(fontSize: widget.fontSize),
                    decoration: const InputDecoration(
                      labelText: 'Confirm New Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.check_circle_outline),
                    ),
                    validator: (value) {
                      if (value != _newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Update Request Trigger Button
                  ElevatedButton(
                    onPressed: _updatePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'UPDATE PASSWORD',
                      style: TextStyle(
                        fontSize: widget.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}