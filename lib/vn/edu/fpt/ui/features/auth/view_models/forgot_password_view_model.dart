import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/forgot_password_state.dart';

enum ForgotPasswordSubmitResult { invalid, success, failure }

class ForgotPasswordViewModel extends ChangeNotifier {
  ForgotPasswordViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  ForgotPasswordState _state = const ForgotPasswordState();
  ForgotPasswordState get state => _state;

  bool get isSubmitting => _state.isSubmitting;

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

  Future<ForgotPasswordSubmitResult> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || _state.isSubmitting) {
      return ForgotPasswordSubmitResult.invalid;
    }

    final phoneNumber = phoneController.text.trim();
    _state = _state.copyWith(
      isSubmitting: true,
      phoneNumber: phoneNumber,
      clearSuccessMessage: true,
      clearErrorMessage: true,
      clearDebugOtp: true,
    );
    notifyListeners();

    final result = await _authRepository.requestPasswordReset(
      phoneNumber: phoneNumber,
    );

    switch (result) {
      case Success(value: final value):
        _state = _state.copyWith(
          isSubmitting: false,
          successMessage: value.message,
          debugOtp: value.debugOtp,
        );
        notifyListeners();
        return ForgotPasswordSubmitResult.success;
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return ForgotPasswordSubmitResult.failure;
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
