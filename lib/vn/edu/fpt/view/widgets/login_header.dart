import 'package:flutter/material.dart';

/// View widget: clean header showing the FPT Schools logo on the page
/// background (no colored banner). Height follows the logo + padding.
class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
      child: Center(
        child: Image.asset(
          'assets/images/fpt_schools_logo.png',
          width: 210,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
