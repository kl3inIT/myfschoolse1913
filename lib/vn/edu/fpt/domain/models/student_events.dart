import 'package:flutter/foundation.dart';

@immutable
class StudentEvents {
  const StudentEvents({required this.featuredEvent, required this.events});

  final StudentEvent? featuredEvent;
  final List<StudentEvent> events;
}

@immutable
class StudentEvent {
  const StudentEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startsAt;
  final DateTime endsAt;
  final StudentEventStatus status;
}

enum StudentEventStatus {
  upcoming('Sắp diễn ra'),
  ongoing('Đang diễn ra'),
  finished('Đã kết thúc');

  const StudentEventStatus(this.label);

  final String label;

  static StudentEventStatus fromApi(String value) {
    return switch (value) {
      'UPCOMING' => StudentEventStatus.upcoming,
      'ONGOING' => StudentEventStatus.ongoing,
      'FINISHED' => StudentEventStatus.finished,
      _ => StudentEventStatus.upcoming,
    };
  }
}
