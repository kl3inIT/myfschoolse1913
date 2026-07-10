import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/dashboard_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/account/view_models/profile_state.dart';

enum ProfileLoadResult { success, failure, sessionExpired }

class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  final DashboardRepository _dashboardRepository;

  ProfileState _state = const ProfileState();
  ProfileState get state => _state;

  Future<ProfileLoadResult> loadProfile() async {
    if (_state.isLoading) {
      return ProfileLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _dashboardRepository.getStudentDashboard();
    switch (result) {
      case Success(value: final dashboard):
        _state = ProfileState(student: dashboard.student);
        notifyListeners();
        return ProfileLoadResult.success;
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
            ? ProfileLoadResult.sessionExpired
            : ProfileLoadResult.failure;
    }
  }
}
