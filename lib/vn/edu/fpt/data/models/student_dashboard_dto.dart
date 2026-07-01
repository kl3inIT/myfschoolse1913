import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_dashboard.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';

class StudentDashboardDto {
  const StudentDashboardDto({
    required this.student,
    required this.shortcuts,
    required this.todaySchedule,
  });

  factory StudentDashboardDto.fromJson(Map<String, Object?> json) {
    return StudentDashboardDto(
      student: DashboardStudentDto.fromJson(
        json['student'] as Map<String, Object?>,
      ),
      shortcuts: (json['shortcuts'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(DashboardShortcutDto.fromJson)
          .toList(growable: false),
      todaySchedule: (json['todaySchedule'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(TodayScheduleItemDto.fromJson)
          .toList(growable: false),
    );
  }

  final DashboardStudentDto student;
  final List<DashboardShortcutDto> shortcuts;
  final List<TodayScheduleItemDto> todaySchedule;

  StudentDashboard toDomain() {
    return StudentDashboard(
      student: student.toDomain(),
      shortcuts: shortcuts
          .map((shortcut) => shortcut.toDomain())
          .toList(growable: false),
      todaySchedule: todaySchedule
          .map((item) => item.toDomain())
          .toList(growable: false),
    );
  }
}

class DashboardStudentDto {
  const DashboardStudentDto({
    required this.id,
    required this.fullName,
    required this.role,
    required this.className,
    required this.schoolYear,
    required this.status,
    required this.initials,
  });

  factory DashboardStudentDto.fromJson(Map<String, Object?> json) {
    return DashboardStudentDto(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      className: json['className'] as String,
      schoolYear: json['schoolYear'] as String,
      status: json['status'] as String,
      initials: json['initials'] as String,
    );
  }

  final String id;
  final String fullName;
  final String role;
  final String className;
  final String schoolYear;
  final String status;
  final String initials;

  DashboardStudent toDomain() {
    return DashboardStudent(
      id: id,
      fullName: fullName,
      role: UserRole.fromApi(role),
      className: className,
      schoolYear: schoolYear,
      status: status,
      initials: initials,
    );
  }
}

class DashboardShortcutDto {
  const DashboardShortcutDto({required this.code, required this.label});

  factory DashboardShortcutDto.fromJson(Map<String, Object?> json) {
    return DashboardShortcutDto(
      code: json['code'] as String,
      label: json['label'] as String,
    );
  }

  final String code;
  final String label;

  DashboardShortcut toDomain() {
    return DashboardShortcut(code: code, label: label);
  }
}

class TodayScheduleItemDto {
  const TodayScheduleItemDto({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  factory TodayScheduleItemDto.fromJson(Map<String, Object?> json) {
    return TodayScheduleItemDto(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      time: json['time'] as String,
    );
  }

  final String title;
  final String subtitle;
  final String time;

  TodayScheduleItem toDomain() {
    return TodayScheduleItem(title: title, subtitle: subtitle, time: time);
  }
}
