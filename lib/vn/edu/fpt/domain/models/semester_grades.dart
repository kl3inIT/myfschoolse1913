import 'package:flutter/foundation.dart';

@immutable
class SemesterGrades {
  const SemesterGrades({
    required this.semester,
    required this.averageScore,
    required this.rank,
    required this.subjects,
  });

  final String semester;
  final double averageScore;
  final String rank;
  final List<SubjectGrade> subjects;
}

@immutable
class SubjectGrade {
  const SubjectGrade({
    required this.name,
    required this.score,
    required this.detail,
  });

  final String name;
  final double score;
  final String detail;
}
