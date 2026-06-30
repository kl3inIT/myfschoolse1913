import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/fpt_schools_logo.png',
        width: 210,
        height: 105,
        fit: BoxFit.contain,
      ),
    );
  }
}
