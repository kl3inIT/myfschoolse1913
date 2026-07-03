import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/applications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/view_models/applications_state.dart';

enum ApplicationsLoadResult { success, failure, sessionExpired }

class ApplicationsViewModel extends ChangeNotifier {
  ApplicationsViewModel({
    required ApplicationsRepository applicationsRepository,
  }) : _applicationsRepository = applicationsRepository;

  final ApplicationsRepository _applicationsRepository;

  ApplicationsState _state = const ApplicationsState();
  ApplicationsState get state => _state;

  Future<ApplicationsLoadResult> loadApplications() async {
    if (_state.isLoading) {
      return ApplicationsLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _applicationsRepository.getApplications();
    switch (result) {
      case Success(value: final applications):
        _state = _state.copyWith(
          isLoading: false,
          applications: applications,
          clearErrorMessage: true,
        );
        notifyListeners();
        return ApplicationsLoadResult.success;
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
            ? ApplicationsLoadResult.sessionExpired
            : ApplicationsLoadResult.failure;
    }
  }

  void selectStatus(StudentApplicationStatus status) {
    if (_state.selectedStatus == status) {
      return;
    }
    _state = _state.copyWith(selectedStatus: status);
    notifyListeners();
  }
}
