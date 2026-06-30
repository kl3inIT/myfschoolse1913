import 'package:flutter/foundation.dart';

@immutable
class ForgotPasswordState {
  const ForgotPasswordState({
    this.isSubmitting = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isSubmitting;
  final String? successMessage;
  final String? errorMessage;

  ForgotPasswordState copyWith({
    bool? isSubmitting,
    String? successMessage,
    String? errorMessage,
    bool clearSuccessMessage = false,
    bool clearErrorMessage = false,
  }) {
    return ForgotPasswordState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
