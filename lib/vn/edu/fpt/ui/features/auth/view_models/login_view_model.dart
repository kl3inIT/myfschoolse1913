import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/login_state.dart';

enum LoginSubmitResult { invalid, success, failure }

class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  LoginState _state = const LoginState();
  LoginState get state => _state;

  bool get obscurePassword => _state.obscurePassword;
  bool get isSubmitting => _state.isSubmitting;

  void toggleObscurePassword() {
    _state = _state.copyWith(obscurePassword: !_state.obscurePassword);
    notifyListeners();
  }

  String? validatePhone(String? value) {
    final phoneNumber = value?.trim() ?? '';
    if (phoneNumber.isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(phoneNumber)) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  Future<LoginSubmitResult> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || _state.isSubmitting) {
      return LoginSubmitResult.invalid;
    }

    _state = _state.copyWith(isSubmitting: true, clearErrorMessage: true);
    notifyListeners();

    final result = await _authRepository.login(
      phoneNumber: phoneController.text.trim(),
      password: passwordController.text,
    );

    switch (result) {
      case Success(value: final session):
        _state = _state.copyWith(
          isSubmitting: false,
          session: session,
          clearErrorMessage: true,
        );
        notifyListeners();
        return LoginSubmitResult.success;
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return LoginSubmitResult.failure;
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
