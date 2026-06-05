import 'package:flutter/material.dart';

import '../../controller/login_controller.dart';

/// View widget: the login form, bound to a [LoginController].
///
/// Reads field state and validators from the controller and forwards the
/// password-visibility toggle to it. UI-feedback actions that need a
/// `BuildContext` (forgot password, login) are injected by the parent View.
class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.controller,
    required this.onForgotPassword,
    required this.onLogin,
  });

  final LoginController controller;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: controller.phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: controller.validatePhone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.passwordController,
            obscureText: controller.obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onLogin(),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: controller.obscurePassword
                    ? 'Hiện mật khẩu'
                    : 'Ẩn mật khẩu',
                icon: Icon(
                  controller.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: controller.toggleObscurePassword,
              ),
            ),
            validator: controller.validatePassword,
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: const Text('Quên mật khẩu?'),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onLogin,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Đăng nhập',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
