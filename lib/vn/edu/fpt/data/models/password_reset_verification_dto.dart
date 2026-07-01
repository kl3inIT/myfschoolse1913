import 'package:myfschoolse1913/vn/edu/fpt/domain/models/password_reset_verification.dart';

class PasswordResetVerificationDto {
  const PasswordResetVerificationDto({required this.resetToken});

  factory PasswordResetVerificationDto.fromJson(Map<String, Object?> json) {
    return PasswordResetVerificationDto(
      resetToken: json['resetToken'] as String,
    );
  }

  final String resetToken;

  PasswordResetVerification toDomain() {
    return PasswordResetVerification(resetToken: resetToken);
  }
}
