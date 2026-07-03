import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_events.dart';

class StudentEventsDto {
  const StudentEventsDto({required this.featuredEvent, required this.events});

  factory StudentEventsDto.fromJson(Map<String, Object?> json) {
    final featuredJson = json['featuredEvent'];
    return StudentEventsDto(
      featuredEvent: featuredJson is Map<String, Object?>
          ? StudentEventDto.fromJson(featuredJson)
          : null,
      events: (json['events'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(StudentEventDto.fromJson)
          .toList(growable: false),
    );
  }

  final StudentEventDto? featuredEvent;
  final List<StudentEventDto> events;

  StudentEvents toDomain() {
    return StudentEvents(
      featuredEvent: featuredEvent?.toDomain(),
      events: events.map((event) => event.toDomain()).toList(growable: false),
    );
  }
}

class StudentEventDto {
  const StudentEventDto({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startsAt,
    required this.endsAt,
    required this.status,
  });

  factory StudentEventDto.fromJson(Map<String, Object?> json) {
    return StudentEventDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      startsAt: DateTime.parse(json['startsAt'] as String).toLocal(),
      endsAt: DateTime.parse(json['endsAt'] as String).toLocal(),
      status: json['status'] as String,
    );
  }

  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startsAt;
  final DateTime endsAt;
  final String status;

  StudentEvent toDomain() {
    return StudentEvent(
      id: id,
      title: title,
      description: description,
      location: location,
      startsAt: startsAt,
      endsAt: endsAt,
      status: StudentEventStatus.fromApi(status),
    );
  }
}
