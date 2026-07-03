import 'package:flutter/foundation.dart';

@immutable
class StudentClubs {
  const StudentClubs({required this.clubs});

  final List<StudentClub> clubs;
}

@immutable
class StudentClub {
  const StudentClub({
    required this.id,
    required this.name,
    required this.description,
    required this.scheduleText,
    required this.location,
    required this.registrationStatus,
  });

  final String id;
  final String name;
  final String description;
  final String scheduleText;
  final String location;
  final ClubRegistrationStatus registrationStatus;

  bool get canRegister =>
      registrationStatus == ClubRegistrationStatus.none ||
      registrationStatus == ClubRegistrationStatus.rejected;
}

enum ClubRegistrationStatus {
  none('', 'Đăng ký'),
  pending('PENDING', 'Chờ duyệt'),
  approved('APPROVED', 'Đang tham gia'),
  rejected('REJECTED', 'Đăng ký lại');

  const ClubRegistrationStatus(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static ClubRegistrationStatus fromWireValue(String? value) {
    return switch (value) {
      'PENDING' => ClubRegistrationStatus.pending,
      'APPROVED' => ClubRegistrationStatus.approved,
      'REJECTED' => ClubRegistrationStatus.rejected,
      _ => ClubRegistrationStatus.none,
    };
  }
}
