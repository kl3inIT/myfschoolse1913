import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';

class StudentClubsDto {
  const StudentClubsDto({required this.clubs});

  factory StudentClubsDto.fromJson(Map<String, Object?> json) {
    return StudentClubsDto(
      clubs: (json['clubs'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(StudentClubDto.fromJson)
          .toList(growable: false),
    );
  }

  final List<StudentClubDto> clubs;

  StudentClubs toDomain() {
    return StudentClubs(
      clubs: clubs.map((club) => club.toDomain()).toList(growable: false),
    );
  }
}

class StudentClubDto {
  const StudentClubDto({
    required this.id,
    required this.name,
    required this.description,
    required this.scheduleText,
    required this.location,
    this.registrationStatus,
  });

  factory StudentClubDto.fromJson(Map<String, Object?> json) {
    return StudentClubDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      scheduleText: json['scheduleText'] as String,
      location: json['location'] as String,
      registrationStatus: json['registrationStatus'] as String?,
    );
  }

  final String id;
  final String name;
  final String description;
  final String scheduleText;
  final String location;
  final String? registrationStatus;

  StudentClub toDomain() {
    return StudentClub(
      id: id,
      name: name,
      description: description,
      scheduleText: scheduleText,
      location: location,
      registrationStatus: ClubRegistrationStatus.fromWireValue(
        registrationStatus,
      ),
    );
  }
}
