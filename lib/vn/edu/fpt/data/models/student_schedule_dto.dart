import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_schedule.dart';

class StudentScheduleDto {
  const StudentScheduleDto({
    required this.weekStart,
    required this.today,
    required this.academicYearName,
    required this.semesterName,
    required this.days,
  });

  factory StudentScheduleDto.fromJson(Map<String, Object?> json) {
    return StudentScheduleDto(
      weekStart: DateTime.parse(json['weekStart'] as String),
      today: DateTime.parse(json['today'] as String),
      academicYearName: json['academicYearName'] as String? ?? '',
      semesterName: json['semesterName'] as String? ?? '',
      days: (json['days'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ScheduleDayDto.fromJson)
          .toList(growable: false),
    );
  }

  final DateTime weekStart;
  final DateTime today;
  final String academicYearName;
  final String semesterName;
  final List<ScheduleDayDto> days;

  StudentSchedule toDomain() {
    return StudentSchedule(
      weekStart: weekStart,
      today: today,
      academicYearName: academicYearName,
      semesterName: semesterName,
      days: days.map((day) => day.toDomain()).toList(growable: false),
    );
  }
}

class ScheduleDayDto {
  const ScheduleDayDto({
    required this.date,
    required this.dayLabel,
    required this.isToday,
    required this.items,
  });

  factory ScheduleDayDto.fromJson(Map<String, Object?> json) {
    return ScheduleDayDto(
      date: DateTime.parse(json['date'] as String),
      dayLabel: json['dayLabel'] as String,
      isToday: json['today'] as bool,
      items: (json['items'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(ScheduleItemDto.fromJson)
          .toList(growable: false),
    );
  }

  final DateTime date;
  final String dayLabel;
  final bool isToday;
  final List<ScheduleItemDto> items;

  ScheduleDay toDomain() {
    return ScheduleDay(
      date: date,
      dayLabel: dayLabel,
      isToday: isToday,
      items: items.map((item) => item.toDomain()).toList(growable: false),
    );
  }
}

class ScheduleItemDto {
  const ScheduleItemDto({
    required this.lessonNumber,
    required this.type,
    required this.title,
    required this.lessonLabel,
    required this.timeRange,
    required this.roomName,
    this.teacherName,
  });

  factory ScheduleItemDto.fromJson(Map<String, Object?> json) {
    return ScheduleItemDto(
      lessonNumber: json['lessonNumber'] as int,
      type: json['slotType'] as String? ?? 'SUBJECT',
      title: json['title'] as String,
      lessonLabel: json['lessonLabel'] as String,
      timeRange: json['timeRange'] as String,
      roomName: json['roomName'] as String? ?? '',
      teacherName: json['teacherName'] as String?,
    );
  }

  final int lessonNumber;
  final String type;
  final String title;
  final String lessonLabel;
  final String timeRange;
  final String roomName;
  final String? teacherName;

  ScheduleItem toDomain() {
    return ScheduleItem(
      lessonNumber: lessonNumber,
      type: ScheduleItemType.fromWireValue(type),
      title: title,
      lessonLabel: lessonLabel,
      timeRange: timeRange,
      roomName: roomName,
      teacherName: teacherName,
    );
  }
}
