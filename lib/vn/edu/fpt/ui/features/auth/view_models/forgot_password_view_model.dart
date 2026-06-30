import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/forgot_password_state.dart';

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

  Future<void> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || _state.isSubmitting) {
      return;
    }

    _state = _state.copyWith(
      isSubmitting: true,
      clearSuccessMessage: true,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _authRepository.requestPasswordReset(
      phoneNumber: phoneController.text.trim(),
    );

    switch (result) {
      case Success():
        _state = _state.copyWith(
          isSubmitting: false,
          successMessage:
              'Nếu số điện thoại hợp lệ, mã xác thực sẽ được gửi trong ít phút.',
        );
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
