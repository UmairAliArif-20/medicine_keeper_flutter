import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final double fontSize;
  final VoidCallback onLoginSuccess; // Callback to unlock the main app

  const LoginPage({
    super.key,
    required this.fontSize,
    required this.onLoginSuccess,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // A local list to simulate registered users for now
  final List<String> _registeredUsers = ['rafaihabbasi@gmail.com'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();

      if (_isLoginMode) {
        // Check if user exists
        if (_registeredUsers.contains(email)) {
          // Success -> Trigger the callback to open the app
          widget.onLoginSuccess();
        } else {
          // Show error message if user doesn't exist
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User does not exist. Please register first.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        // Registration Mode logic
        if (!_registeredUsers.contains(email)) {
          _registeredUsers.add(email);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful! Please login.'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _isLoginMode = true;
            _confirmPasswordController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email is already registered.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold here handles the standalone login page look (no global Appbar/BottomBar)
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isLoginMode ? 'Welcome Back' : 'Create Account',
                  style: TextStyle(
                    fontSize: widget.fontSize + 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _isLoginMode
                      ? 'Please sign in to continue'
                      : 'Fill in the details to get started',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: widget.fontSize,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(fontSize: widget.fontSize),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(fontSize: widget.fontSize),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),

                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    style: TextStyle(fontSize: widget.fontSize),
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_clock_outlined),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isLoginMode ? 'LOGIN' : 'REGISTER',
                    style: TextStyle(fontSize: widget.fontSize),
                  ),
                ),
                const SizedBox(height: 16),

                // Toggle Auth Mode Links
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLoginMode = !_isLoginMode;
                      _formKey.currentState?.reset();
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
    );
  }
}