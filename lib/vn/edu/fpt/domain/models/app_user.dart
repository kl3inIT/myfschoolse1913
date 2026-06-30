import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.role,
  });

  final String id;
  final String phoneNumber;
  final String fullName;
  final UserRole role;
}
