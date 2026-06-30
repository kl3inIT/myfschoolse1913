import 'package:flutter/foundation.dart';

@immutable
class LoginState {
  const LoginState({
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final bool obscurePassword;
  final bool isSubmitting;
  final String? errorMessage;

  LoginState copyWith({
    bool? obscurePassword,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
