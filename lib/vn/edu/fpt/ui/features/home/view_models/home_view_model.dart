import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/dashboard_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/home/view_models/home_state.dart';

enum HomeLoadResult { success, failure, sessionExpired }

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required DashboardRepository dashboardRepository})
    : _dashboardRepository = dashboardRepository;

  final DashboardRepository _dashboardRepository;

  HomeState _state = const HomeState();
  HomeState get state => _state;

  Future<HomeLoadResult> loadDashboard() async {
    if (_state.isLoading) {
      return HomeLoadResult.failure;
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
        _state = HomeState(dashboard: dashboard);
        notifyListeners();
        return HomeLoadResult.success;
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
            ? HomeLoadResult.sessionExpired
            : HomeLoadResult.failure;
    }
  }
}
