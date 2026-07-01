import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/semester_grades.dart';

@immutable
class SemesterGradesState {
  const SemesterGradesState({
    this.isLoading = false,
    this.grades,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final SemesterGrades? grades;
  final String? errorMessage;
  final bool sessionExpired;

  SemesterGradesState copyWith({
    bool? isLoading,
    SemesterGrades? grades,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return SemesterGradesState(
      isLoading: isLoading ?? this.isLoading,
      grades: grades ?? this.grades,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
