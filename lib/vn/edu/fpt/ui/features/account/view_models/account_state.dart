import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/app_user.dart';

@immutable
class AccountState {
  const AccountState({
    this.isLoading = false,
    this.isLoggingOut = false,
    this.user,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final bool isLoggingOut;
  final AppUser? user;
  final String? errorMessage;
  final bool sessionExpired;

  AccountState copyWith({
    bool? isLoading,
    bool? isLoggingOut,
    AppUser? user,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
      user: user ?? this.user,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
