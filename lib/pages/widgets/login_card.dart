import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class LoginCard extends StatefulWidget {
  const LoginCard({
    super.key,
    required this.fontSize,
    required this.accounts,
    required this.onRegister,
    required this.onLoginSuccess,
  });

  final double fontSize;
  final List<Map<String, dynamic>> accounts;
  final ValueChanged<Map<String, dynamic>> onRegister;
  final ValueChanged<Map<String, dynamic>> onLoginSuccess;

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
  }

  void _handleSubmit() {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (_isLoginMode) {
      final account = widget.accounts.cast<Map<String, dynamic>?>().firstWhere(
            (acc) => acc?['email'] == email && acc?['password'] == password,
            orElse: () => null,
          );

      if (account != null) {
        widget.onLoginSuccess(account);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    } else {
      final String name = _nameController.text.trim();
      if (name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your name')),
        );
        return;
      }

      if (widget.accounts.any((acc) => acc['email'] == email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered')),
        );
        return;
      }

      final newAccount = {
        'email': email,
        'password': password,
        'name': name,
      };
      widget.onRegister(newAccount);
      widget.onLoginSuccess(newAccount);
    }
  }

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
    final ColorScheme scheme = Theme.of(context).colorScheme;

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
                color: scheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _isLoginMode ? Icons.lock : Icons.person_add,
                color: scheme.primary,
                size: 34,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _isLoginMode ? 'Welcome Back' : 'Create Account',
              style: TextStyle(
                fontSize: widget.fontSize + 8,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            if (!_isLoginMode) ...[
              TextField(
                controller: _nameController,
                style: baseTextStyle,
                decoration: _buildFieldDecoration(Icons.person_outline, 'Name'),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _emailController,
              style: baseTextStyle,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildFieldDecoration(Icons.email_outlined, 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              style: baseTextStyle,
              decoration: _buildFieldDecoration(Icons.lock_outline, 'Password'),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _isLoginMode ? 'Login' : 'Register',
                  style: TextStyle(fontSize: widget.fontSize),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _toggleMode,
              child: Text(
                _isLoginMode
                    ? "Don't have an account? Register"
                    : "Already have an account? Login",
                style: TextStyle(fontSize: widget.fontSize - 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
