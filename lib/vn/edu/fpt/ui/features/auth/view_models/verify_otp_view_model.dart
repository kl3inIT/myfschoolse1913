import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/verify_otp_state.dart';

enum VerifyOtpSubmitResult { invalid, success, failure }

class VerifyOtpViewModel extends ChangeNotifier {
  VerifyOtpViewModel({
    required AuthRepository authRepository,
    required this.phoneNumber,
  }) : _authRepository = authRepository;

  final AuthRepository _authRepository;
  final String phoneNumber;
  final formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  VerifyOtpState _state = const VerifyOtpState();
  VerifyOtpState get state => _state;

  bool get isSubmitting => _state.isSubmitting;

  String? validateOtp(String? value) {
    final otp = value?.trim() ?? '';
    if (otp.isEmpty) {
      return 'Vui lòng nhập mã xác thực';
    }
    if (!RegExp(r'^[0-9]{6}$').hasMatch(otp)) {
      return 'Mã xác thực gồm 6 chữ số';
    }
    return null;
  }

  Future<VerifyOtpSubmitResult> submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || _state.isSubmitting) {
      return VerifyOtpSubmitResult.invalid;
    }

    _state = _state.copyWith(isSubmitting: true, clearErrorMessage: true);
    notifyListeners();

    final result = await _authRepository.verifyPasswordResetOtp(
      phoneNumber: phoneNumber,
      otp: otpController.text.trim(),
    );

    switch (result) {
      case Success(value: final value):
        _state = _state.copyWith(
          isSubmitting: false,
          resetToken: value.resetToken,
        );
        notifyListeners();
        return VerifyOtpSubmitResult.success;
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return VerifyOtpSubmitResult.failure;
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }
}
