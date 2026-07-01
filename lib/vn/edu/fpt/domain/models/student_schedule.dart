import 'package:flutter/foundation.dart';

@immutable
class StudentSchedule {
  const StudentSchedule({
    required this.weekStart,
    required this.today,
    required this.days,
  });

  final DateTime weekStart;
  final DateTime today;
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
    required this.title,
    required this.lessonLabel,
    required this.timeRange,
    required this.roomName,
    this.teacherName,
  });

  final int lessonNumber;
  final String title;
  final String lessonLabel;
  final String timeRange;
  final String roomName;
  final String? teacherName;
}
