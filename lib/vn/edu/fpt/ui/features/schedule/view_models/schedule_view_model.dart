import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/schedule_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/schedule/view_models/schedule_state.dart';

enum ScheduleLoadResult { success, failure, sessionExpired }

class ScheduleViewModel extends ChangeNotifier {
  ScheduleViewModel({required ScheduleRepository scheduleRepository})
    : _scheduleRepository = scheduleRepository;

  final ScheduleRepository _scheduleRepository;

  ScheduleState _state = const ScheduleState();
  ScheduleState get state => _state;

  Future<ScheduleLoadResult> loadSchedule({DateTime? weekStart}) async {
    if (_state.isLoading) {
      return ScheduleLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _scheduleRepository.getSchedule(weekStart: weekStart);
    switch (result) {
      case Success(value: final schedule):
        _state = ScheduleState(schedule: schedule);
        notifyListeners();
        return ScheduleLoadResult.success;
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
            ? ScheduleLoadResult.sessionExpired
            : ScheduleLoadResult.failure;
    }
  }
}
