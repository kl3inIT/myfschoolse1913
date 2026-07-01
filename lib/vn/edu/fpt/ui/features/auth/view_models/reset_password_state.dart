import 'package:flutter/foundation.dart';

@immutable
class ResetPasswordState {
  const ResetPasswordState({
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final bool isSubmitting;
  final String? errorMessage;

  ResetPasswordState copyWith({
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ResetPasswordState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword:
          obscureConfirmPassword ?? this.obscureConfirmPassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
