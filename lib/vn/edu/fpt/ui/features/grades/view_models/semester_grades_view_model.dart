import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/grades_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/grades/view_models/semester_grades_state.dart';

enum SemesterGradesLoadResult { success, failure, sessionExpired }

class SemesterGradesViewModel extends ChangeNotifier {
  SemesterGradesViewModel({required GradesRepository gradesRepository})
    : _gradesRepository = gradesRepository;

  final GradesRepository _gradesRepository;

  SemesterGradesState _state = const SemesterGradesState();
  SemesterGradesState get state => _state;

  Future<SemesterGradesLoadResult> loadGrades() async {
    if (_state.isLoading) {
      return SemesterGradesLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _gradesRepository.getSemesterGrades();
    switch (result) {
      case Success(value: final grades):
        _state = SemesterGradesState(grades: grades);
        notifyListeners();
        return SemesterGradesLoadResult.success;
      case Failure(failure: final failure):
        final sessionExpired =
            failure.cause is ApiException &&
            (failure.cause! as ApiException).statusCode == 401;
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          sessionExpired: sessionExpired,
        );
        notifyListeners();
        return sessionExpired
            ? SemesterGradesLoadResult.sessionExpired
            : SemesterGradesLoadResult.failure;
    }
  }
}
