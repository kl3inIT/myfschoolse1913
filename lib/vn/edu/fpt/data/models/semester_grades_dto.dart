import 'package:myfschoolse1913/vn/edu/fpt/domain/models/semester_grades.dart';

class SemesterGradesDto {
  const SemesterGradesDto({
    required this.semester,
    required this.averageScore,
    required this.rank,
    required this.subjects,
  });

  factory SemesterGradesDto.fromJson(Map<String, Object?> json) {
    return SemesterGradesDto(
      semester: json['semester'] as String,
      averageScore: (json['averageScore'] as num).toDouble(),
      rank: json['rank'] as String,
      subjects: (json['subjects'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(SubjectGradeDto.fromJson)
          .toList(growable: false),
    );
  }

  final String semester;
  final double averageScore;
  final String rank;
  final List<SubjectGradeDto> subjects;

  SemesterGrades toDomain() {
    return SemesterGrades(
      semester: semester,
      averageScore: averageScore,
      rank: rank,
      subjects: subjects
          .map((subject) => subject.toDomain())
          .toList(growable: false),
    );
  }
}

class SubjectGradeDto {
  const SubjectGradeDto({
    required this.name,
    required this.score,
    required this.detail,
  });

  factory SubjectGradeDto.fromJson(Map<String, Object?> json) {
    return SubjectGradeDto(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
      detail: json['detail'] as String,
    );
  }

  final String name;
  final double score;
  final String detail;

  SubjectGrade toDomain() {
    return SubjectGrade(name: name, score: score, detail: detail);
  }
}
