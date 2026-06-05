import 'package:flutter/foundation.dart';

/// Model: immutable snapshot of the login form state.
///
/// Role is intentionally absent — it is assigned by the admin at account
/// creation and resolved by the backend, not chosen on the client.
@immutable
class LoginModel {
  const LoginModel({this.obscurePassword = true});

  final bool obscurePassword;

  LoginModel copyWith({bool? obscurePassword}) {
    return LoginModel(obscurePassword: obscurePassword ?? this.obscurePassword);
  }
}
