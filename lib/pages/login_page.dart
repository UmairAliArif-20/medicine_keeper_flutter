import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  final double fontSize;
  final ValueChanged<Map<String, dynamic>> onLoginSuccess;
  final ValueChanged<Map<String, dynamic>> onRegister;
  final List<Map<String, dynamic>> accounts;

  const LoginPage({
    super.key,
    required this.fontSize,
    required this.onLoginSuccess,
    required this.onRegister,
    required this.accounts,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _findAccountByEmail(String email) {
    for (final Map<String, dynamic> account in widget.accounts) {
      if ((account['email'] as String).toLowerCase() == email.toLowerCase()) {
        return account;
      }
    }
    return null;
  }

  InputDecoration _buildFieldDecoration(IconData icon, String hintText) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return InputDecoration(
      prefixIcon: Icon(icon, color: scheme.onSurfaceVariant),
      hintText: hintText,
      hintStyle: TextStyle(
        fontSize: widget.fontSize - 1,
        color: scheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim().toLowerCase();
      String password = _passwordController.text;

      Map<String, dynamic>? existingAccount = _findAccountByEmail(email);

      if (_isLoginMode) {
        if (existingAccount == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User does not exist. Please register first.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        String storedPassword = existingAccount['password'] as String? ?? '';
        if (storedPassword != password) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Incorrect password. Please try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
          return;
        }

        widget.onLoginSuccess(existingAccount);
        return;
      }

      if (existingAccount != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is already registered.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      Map<String, dynamic> newAccount = <String, dynamic>{
        'email': email,
        'password': password,
        'name': _nameController.text.trim(),
      };

      widget.onRegister(newAccount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please login.'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _isLoginMode = true;
        _confirmPasswordController.clear();
        _nameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    TextStyle baseTextStyle = TextStyle(fontSize: widget.fontSize);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              scheme.primary.withValues(alpha: 0.08),
              scheme.secondary.withValues(alpha: 0.25),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: scheme.surface,
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          _isLoginMode
                              ? Icons.lock_outline
                              : Icons.person_add_alt,
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
                          color: scheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isLoginMode
                            ? 'Sign in to continue'
                            : 'Fill in the details to get started',
                        style: TextStyle(
                          fontSize: widget.fontSize - 2,
                          color: scheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),
                      if (!_isLoginMode) ...[
                        TextFormField(
                          controller: _nameController,
                          style: baseTextStyle,
                          decoration: _buildFieldDecoration(
                            Icons.person_outline,
                            'Full Name',
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: baseTextStyle,
                        decoration: _buildFieldDecoration(
                          Icons.email_outlined,
                          'Email',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: baseTextStyle,
                        decoration: _buildFieldDecoration(
                          Icons.lock_outline,
                          'Password',
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      if (!_isLoginMode) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          style: baseTextStyle,
                          decoration: _buildFieldDecoration(
                            Icons.lock_clock_outlined,
                            'Confirm Password',
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          _isLoginMode ? 'LOGIN' : 'REGISTER',
                          style: TextStyle(fontSize: widget.fontSize),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            _formKey.currentState?.reset();
                            _confirmPasswordController.clear();
                            _nameController.clear();
                          });
                        },
                        child: Text(
                          _isLoginMode
                              ? "Don't have an account? Register here"
                              : "Already have an account? Login here",
                          style: TextStyle(fontSize: widget.fontSize),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
