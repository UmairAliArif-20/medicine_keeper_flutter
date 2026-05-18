import 'package:flutter/material.dart';

class AccountPage extends StatefulWidget {
  final double fontSize;
  final Map<String, dynamic> account;
  final ValueChanged<Map<String, dynamic>> onUpdate;
  final VoidCallback onLogout;

  const AccountPage({
    super.key,
    required this.fontSize,
    required this.account,
    required this.onUpdate,
    required this.onLogout,
  });

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late TextEditingController _nameController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account['name']);
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final updatedAccount = Map<String, dynamic>.from(widget.account);
    updatedAccount['name'] = _nameController.text.trim();
    widget.onUpdate(updatedAccount);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _showChangePasswordDialog() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog<void>(
      context: context,
      builder: (context) {
        final ColorScheme scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: Text(
            'Change Password',
            style: TextStyle(fontSize: widget.fontSize + 2),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _oldPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: TextStyle(fontSize: widget.fontSize),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: widget.fontSize),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: TextStyle(fontSize: widget.fontSize),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: widget.fontSize),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: TextStyle(fontSize: widget.fontSize),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(fontSize: widget.fontSize),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
            ElevatedButton(
              onPressed: _handlePasswordChange,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: Text(
                'Update Password',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handlePasswordChange() {
    final String oldPassword = _oldPasswordController.text;
    final String newPassword = _newPasswordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    // Validate old password
    if (oldPassword != widget.account['password']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current password is incorrect')),
      );
      return;
    }

    // Validate new password
    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password cannot be empty')),
      );
      return;
    }

    // Validate password match
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    // Update password
    final updatedAccount = Map<String, dynamic>.from(widget.account);
    updatedAccount['password'] = newPassword;
    widget.onUpdate(updatedAccount);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully')),
    );
  }

  void _resetPasswordToDefault() {
    showDialog<void>(
      context: context,
      builder: (context) {
        final ColorScheme scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: scheme.surface,
          title: Text(
            'Reset Password',
            style: TextStyle(fontSize: widget.fontSize + 2),
          ),
          content: Text(
            'Reset your password to the default (123456)?',
            style: TextStyle(fontSize: widget.fontSize),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedAccount = Map<String, dynamic>.from(
                  widget.account,
                );
                updatedAccount['password'] = '123456';
                widget.onUpdate(updatedAccount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password reset to default')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: Text('Reset', style: TextStyle(fontSize: widget.fontSize)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: scheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.account['email'] ?? 'Guest',
            style: TextStyle(
              fontSize: widget.fontSize,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(fontSize: widget.fontSize),
              border: const OutlineInputBorder(),
            ),
            style: TextStyle(fontSize: widget.fontSize),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
              ),
              child: Text(
                'Update Profile',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showChangePasswordDialog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: scheme.secondary,
                foregroundColor: scheme.onSecondary,
              ),
              child: Text(
                'Change Password',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _resetPasswordToDefault,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: scheme.tertiaryContainer,
                foregroundColor: scheme.onTertiaryContainer,
              ),
              child: Text(
                'Reset Password to Default',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.onLogout,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: scheme.error),
                foregroundColor: scheme.error,
              ),
              child: Text(
                'Logout',
                style: TextStyle(fontSize: widget.fontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
