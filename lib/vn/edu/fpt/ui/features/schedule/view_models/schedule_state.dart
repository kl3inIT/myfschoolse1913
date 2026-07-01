import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_schedule.dart';

@immutable
class ScheduleState {
  const ScheduleState({
    this.isLoading = false,
    this.schedule,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentSchedule? schedule;
  final String? errorMessage;
  final bool sessionExpired;

  ScheduleState copyWith({
    bool? isLoading,
    StudentSchedule? schedule,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return ScheduleState(
      isLoading: isLoading ?? this.isLoading,
      schedule: schedule ?? this.schedule,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
