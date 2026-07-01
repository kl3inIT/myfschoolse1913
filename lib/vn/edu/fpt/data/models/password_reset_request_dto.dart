import 'package:myfschoolse1913/vn/edu/fpt/domain/models/password_reset_request_result.dart';

class PasswordResetRequestDto {
  const PasswordResetRequestDto({
    required this.message,
    required this.debugOtp,
  });

  factory PasswordResetRequestDto.fromJson(Map<String, Object?> json) {
    return PasswordResetRequestDto(
      message: json['message'] as String,
      debugOtp: json['debugOtp'] as String?,
    );
  }

  final String message;
  final String? debugOtp;

  PasswordResetRequestResult toDomain() {
    return PasswordResetRequestResult(message: message, debugOtp: debugOtp);
  }
}
