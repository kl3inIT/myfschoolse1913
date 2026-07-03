import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';

class StudentApplicationsDto {
  const StudentApplicationsDto({required this.applications});

  factory StudentApplicationsDto.fromJson(Map<String, Object?> json) {
    return StudentApplicationsDto(
      applications: (json['applications'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(StudentApplicationDto.fromJson)
          .toList(growable: false),
    );
  }

  final List<StudentApplicationDto> applications;

  StudentApplications toDomain() {
    return StudentApplications(
      applications: applications
          .map((application) => application.toDomain())
          .toList(growable: false),
    );
  }
}

class StudentApplicationDto {
  const StudentApplicationDto({
    required this.id,
    required this.type,
    required this.status,
    required this.title,
    required this.summary,
    required this.targetDate,
    this.requestedTime,
  });

  factory StudentApplicationDto.fromJson(Map<String, Object?> json) {
    return StudentApplicationDto(
      id: json['id'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      targetDate: DateTime.parse(json['targetDate'] as String),
      requestedTime: json['requestedTime'] as String?,
    );
  }

  final String id;
  final String type;
  final String status;
  final String title;
  final String summary;
  final DateTime targetDate;
  final String? requestedTime;

  StudentApplication toDomain() {
    return StudentApplication(
      id: id,
      type: StudentApplicationType.fromWireValue(type),
      status: StudentApplicationStatus.fromWireValue(status),
      title: title,
      summary: summary,
      targetDate: targetDate,
      requestedTime: requestedTime,
    );
  }
}
