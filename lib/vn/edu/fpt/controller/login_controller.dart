import 'package:flutter/material.dart';

import '../model/login_model.dart';

/// Result of a login attempt, returned by [LoginController.submit] so the
/// View can decide what UI feedback (e.g. a SnackBar) to show.
enum LoginResult { invalid, success }

/// Controller: owns the form state and business logic for the login screen.
///
/// Extends [ChangeNotifier] so the View can rebuild when the model changes.
/// Knows nothing about [BuildContext] or widgets — keeps logic unit-testable.
class LoginController extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  LoginModel _model = const LoginModel();
  LoginModel get model => _model;

  bool get obscurePassword => _model.obscurePassword;

  void toggleObscurePassword() {
    _model = _model.copyWith(obscurePassword: !_model.obscurePassword);
    notifyListeners();
  }

  String? validatePhone(String? value) =>
      (value == null || value.trim().isEmpty)
      ? 'Vui lòng nhập số điện thoại'
      : null;

  String? validatePassword(String? value) =>
      (value == null || value.isEmpty) ? 'Vui lòng nhập mật khẩu' : null;

  /// Validates the form. Real authentication is not implemented yet.
  LoginResult submit() {
    final isValid = formKey.currentState?.validate() ?? false;
    return isValid ? LoginResult.success : LoginResult.invalid;
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
