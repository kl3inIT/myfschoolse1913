import 'package:flutter/foundation.dart';

@immutable
class StudentSchedule {
  const StudentSchedule({
    required this.weekStart,
    required this.today,
    required this.academicYearName,
    required this.semesterName,
    required this.days,
  });

  final DateTime weekStart;
  final DateTime today;
  final String academicYearName;
  final String semesterName;
  final List<ScheduleDay> days;

  ScheduleDay? get todaySchedule {
    for (final day in days) {
      if (day.isToday) {
        return day;
      }
    }
    return null;
  }
}

@immutable
class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.dayLabel,
    required this.isToday,
    required this.items,
  });

  final DateTime date;
  final String dayLabel;
  final bool isToday;
  final List<ScheduleItem> items;
}

@immutable
class ScheduleItem {
  const ScheduleItem({
    required this.lessonNumber,
    required this.type,
    required this.session,
    required this.title,
    required this.lessonLabel,
    required this.timeRange,
    required this.roomName,
    this.teacherName,
  });

  final int lessonNumber;
  final ScheduleItemType type;
  final ScheduleSession session;
  final String title;
  final String lessonLabel;
  final String timeRange;
  final String roomName;
  final String? teacherName;
}

enum ScheduleItemType {
  subject,
  meal,
  activity;

  static ScheduleItemType fromWireValue(String value) {
    return switch (value) {
      'MEAL' => ScheduleItemType.meal,
      'ACTIVITY' => ScheduleItemType.activity,
      _ => ScheduleItemType.subject,
    };
  }
}

enum ScheduleSession {
  morning('MORNING', 'Buổi sáng'),
  noon('NOON', 'Nghỉ trưa'),
  afternoon('AFTERNOON', 'Buổi chiều');

  const ScheduleSession(this.wireValue, this.label);

  final String wireValue;
  final String label;

  static ScheduleSession fromWireValue(String value) {
    return switch (value) {
      'NOON' => ScheduleSession.noon,
      'AFTERNOON' => ScheduleSession.afternoon,
      _ => ScheduleSession.morning,
    };
  }
}
