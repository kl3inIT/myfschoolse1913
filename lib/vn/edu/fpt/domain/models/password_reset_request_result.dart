class PasswordResetRequestResult {
  const PasswordResetRequestResult({
    required this.message,
    required this.debugOtp,
  });

  final String message;
  final String? debugOtp;
}
