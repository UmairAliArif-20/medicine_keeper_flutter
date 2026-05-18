import 'package:flutter/material.dart';
import 'widgets/login_card.dart';

// --- PAGE 3: LOGIN ---
class LoginPage extends StatelessWidget {
  final double fontSize;
  const LoginPage({super.key, required this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LoginCard(fontSize: fontSize),
        ),
      ),
    );
  }
}
