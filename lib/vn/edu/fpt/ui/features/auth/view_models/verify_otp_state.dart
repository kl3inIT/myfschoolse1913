import 'package:flutter/foundation.dart';

@immutable
class VerifyOtpState {
  const VerifyOtpState({
    this.isSubmitting = false,
    this.errorMessage,
    this.resetToken,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final String? resetToken;

  VerifyOtpState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    String? resetToken,
    bool clearErrorMessage = false,
  }) {
    return VerifyOtpState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      resetToken: resetToken ?? this.resetToken,
    );
  }
}
