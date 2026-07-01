import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/auth_session.dart';

@immutable
class LoginState {
  const LoginState({
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.errorMessage,
    this.session,
  });

  final bool obscurePassword;
  final bool isSubmitting;
  final String? errorMessage;
  final AuthSession? session;

  LoginState copyWith({
    bool? obscurePassword,
    bool? isSubmitting,
    String? errorMessage,
    AuthSession? session,
    bool clearErrorMessage = false,
    bool clearSession = false,
  }) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      session: clearSession ? null : session ?? this.session,
    );
  }
}
