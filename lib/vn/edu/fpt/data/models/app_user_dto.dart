import 'package:myfschoolse1913/vn/edu/fpt/domain/models/app_user.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';

class AppUserDto {
  const AppUserDto({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
  });

  factory AppUserDto.fromJson(Map<String, Object?> json) {
    return AppUserDto(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
    );
  }

  final String id;
  final String phoneNumber;
  final String fullName;
  final String role;

  AppUser toDomain() {
    return AppUser(
      id: id,
      phoneNumber: phoneNumber,
      fullName: fullName,
      role: UserRole.fromApi(role),
    );
  }
}
