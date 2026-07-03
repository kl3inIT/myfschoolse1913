import 'package:myfschoolse1913/vn/edu/fpt/domain/models/semester_grades.dart';

class SemesterGradesDto {
  const SemesterGradesDto({
    required this.academicYear,
    required this.semester,
    required this.className,
    required this.averageScore,
    required this.rank,
    required this.note,
    required this.subjects,
  });

  factory SemesterGradesDto.fromJson(Map<String, Object?> json) {
    return SemesterGradesDto(
      academicYear: json['academicYear'] as String,
      semester: json['semester'] as String,
      className: json['className'] as String,
      averageScore: (json['averageScore'] as num).toDouble(),
      rank: json['rank'] as String,
      note: json['note'] as String,
      subjects: (json['subjects'] as List<Object?>)
          .cast<Map<String, Object?>>()
          .map(SubjectGradeDto.fromJson)
          .toList(growable: false),
    );
  }

  final String academicYear;
  final String semester;
  final String className;
  final double averageScore;
  final String rank;
  final String note;
  final List<SubjectGradeDto> subjects;

  SemesterGrades toDomain() {
    return SemesterGrades(
      academicYear: academicYear,
      semester: semester,
      className: className,
      averageScore: averageScore,
      rank: rank,
      note: note,
      subjects: subjects
          .map((subject) => subject.toDomain())
          .toList(growable: false),
    );
  }
}

class SubjectGradeDto {
  const SubjectGradeDto({
    required this.name,
    required this.formativeScore,
    required this.midtermScore,
    required this.finalScore,
    required this.score,
    required this.status,
    required this.detail,
    required this.teacherComment,
  });

  factory SubjectGradeDto.fromJson(Map<String, Object?> json) {
    return SubjectGradeDto(
      name: json['name'] as String,
      formativeScore: (json['formativeScore'] as num).toDouble(),
      midtermScore: (json['midtermScore'] as num).toDouble(),
      finalScore: (json['finalScore'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      status: json['status'] as String,
      detail: json['detail'] as String,
      teacherComment: json['teacherComment'] as String? ?? '',
    );
  }

  final String name;
  final double formativeScore;
  final double midtermScore;
  final double finalScore;
  final double score;
  final String status;
  final String detail;
  final String teacherComment;

  SubjectGrade toDomain() {
    return SubjectGrade(
      name: name,
      formativeScore: formativeScore,
      midtermScore: midtermScore,
      finalScore: finalScore,
      score: score,
      status: status,
      detail: detail,
      teacherComment: teacherComment,
    );
  }
}
