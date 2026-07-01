import 'package:flutter/foundation.dart';

@immutable
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isSubmitting = false,
    this.successMessage,
    this.errorMessage,
    this.phoneNumber,
    this.debugOtp,
  });

  final bool isSubmitting;
  final String? successMessage;
  final String? errorMessage;
  final String? phoneNumber;
  final String? debugOtp;

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    String? successMessage,
    String? errorMessage,
    String? phoneNumber,
    String? debugOtp,
    bool clearSuccessMessage = false,
    bool clearErrorMessage = false,
    bool clearDebugOtp = false,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      debugOtp: clearDebugOtp ? null : debugOtp ?? this.debugOtp,
    );
  }
}
