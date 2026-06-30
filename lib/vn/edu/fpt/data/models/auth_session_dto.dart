import 'package:myfschoolse1913/vn/edu/fpt/data/models/app_user_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/auth_session.dart';

class AuthSessionDto {
  const AuthSessionDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresInSeconds,
    required this.user,
  });

  factory AuthSessionDto.fromJson(Map<String, Object?> json) {
    return AuthSessionDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresInSeconds: json['expiresInSeconds'] as int,
      user: AppUserDto.fromJson(json['user'] as Map<String, Object?>),
    );
  }

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInSeconds;
  final AppUserDto user;

  AuthSession toDomain(DateTime issuedAt) {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresAt: issuedAt.add(Duration(seconds: expiresInSeconds)),
      user: user.toDomain(),
    );
  }
}
