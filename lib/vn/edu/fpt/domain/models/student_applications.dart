import 'package:flutter/foundation.dart';

@immutable
class StudentApplications {
  const StudentApplications({required this.applications});

  final List<StudentApplication> applications;
}

@immutable
class StudentApplication {
  const StudentApplication({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.summary,
    required this.targetDate,
    this.requestedTime,
  });

  final String id;
  final StudentApplicationType type;
  final StudentApplicationStatus status;
  final String title;
  final String summary;
  final DateTime targetDate;
  final String? requestedTime;
}

enum StudentApplicationType {
  absence('ABSENCE', 'Nghỉ học'),
  earlyPickup('EARLY_PICKUP', 'Đón sớm'),
  mealRegistration('MEAL_REGISTRATION', 'Suất ăn');

  const StudentApplicationType(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static StudentApplicationType fromWireValue(String value) {
    return switch (value) {
      'EARLY_PICKUP' => StudentApplicationType.earlyPickup,
      'MEAL_REGISTRATION' => StudentApplicationType.mealRegistration,
      _ => StudentApplicationType.absence,
    };
  }
}

enum StudentApplicationStatus {
  pending('PENDING', 'Đang xử lý'),
  approved('APPROVED', 'Đã duyệt'),
  rejected('REJECTED', 'Từ chối');

  const StudentApplicationStatus(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static StudentApplicationStatus fromWireValue(String value) {
    return switch (value) {
      'APPROVED' => StudentApplicationStatus.approved,
      'REJECTED' => StudentApplicationStatus.rejected,
      _ => StudentApplicationStatus.pending,
    };
  }
}
