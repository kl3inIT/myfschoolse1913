import 'package:flutter/foundation.dart';

@immutable
class SemesterGrades {
  const SemesterGrades({
    required this.academicYear,
    required this.semester,
    required this.className,
    required this.averageScore,
    required this.rank,
    required this.note,
    required this.subjects,
  });

  final String academicYear;
  final String semester;
  final String className;
  final double averageScore;
  final String rank;
  final String note;
  final List<SubjectGrade> subjects;
}

@immutable
class SubjectGrade {
  const SubjectGrade({
    required this.name,
    required this.formativeScore,
    required this.midtermScore,
    required this.finalScore,
    required this.score,
    required this.status,
    required this.detail,
    required this.teacherComment,
  });

  final String name;
  final double formativeScore;
  final double midtermScore;
  final double finalScore;
  final double score;
  final String status;
  final String detail;
  final String teacherComment;
}
