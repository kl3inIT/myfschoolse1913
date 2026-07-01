import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/reset_password_state.dart';

enum ResetPasswordSubmitResult { invalid, success, failure }

class ResetPasswordViewModel extends ChangeNotifier {
  ResetPasswordViewModel({
    required AuthRepository authRepository,
    required this.resetToken,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final String resetToken;
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  ResetPasswordState _state = const ResetPasswordState();
  ResetPasswordState get state => _state;

  bool get obscurePassword => _state.obscurePassword;
  bool get obscureConfirmPassword => _state.obscureConfirmPassword;
  bool get isSubmitting => _state.isSubmitting;

  void toggleObscurePassword() {
    _state = _state.copyWith(obscurePassword: !_state.obscurePassword);
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _state = _state.copyWith(
      obscureConfirmPassword: !_state.obscureConfirmPassword,
    );
    notifyListeners();
  }

  String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (password.length < 8) {
      return 'Mật khẩu cần ít nhất 8 ký tự';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';
    if (confirmPassword.isEmpty) {
      return 'Vui lòng nhập lại mật khẩu';
    }
    if (confirmPassword != passwordController.text) {
      return 'Mật khẩu nhập lại không khớp';
    }
    return null;
  }

  Future<ResetPasswordSubmitResult> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || _state.isSubmitting) {
      return ResetPasswordSubmitResult.invalid;
    }

    _state = _state.copyWith(isSubmitting: true, clearErrorMessage: true);
    notifyListeners();

    final result = await _authRepository.confirmPasswordReset(
      resetToken: resetToken,
      newPassword: passwordController.text,
    );

    switch (result) {
      case Success():
        _state = _state.copyWith(isSubmitting: false, clearErrorMessage: true);
        notifyListeners();
        return ResetPasswordSubmitResult.success;
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return ResetPasswordSubmitResult.failure;
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
