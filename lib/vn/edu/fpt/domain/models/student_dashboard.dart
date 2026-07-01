import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';

@immutable
class StudentDashboard {
  const StudentDashboard({
    required this.student,
    required this.shortcuts,
    required this.todaySchedule,
  });

  final DashboardStudent student;
  final List<DashboardShortcut> shortcuts;
  final List<TodayScheduleItem> todaySchedule;
}

@immutable
class DashboardStudent {
  const DashboardStudent({
    required this.id,
    required this.fullName,
    required this.role,
    required this.className,
    required this.schoolYear,
    required this.status,
    required this.initials,
  });

  final String id;
  final String fullName;
  final UserRole role;
  final String className;
  final String schoolYear;
  final String status;
  final String initials;
}

@immutable
class DashboardShortcut {
  const DashboardShortcut({required this.code, required this.label});

  final String code;
  final String label;
}

@immutable
class TodayScheduleItem {
  const TodayScheduleItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final String title;
  final String subtitle;
  final String time;
}
