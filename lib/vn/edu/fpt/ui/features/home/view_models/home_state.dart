import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_dashboard.dart';

@immutable
class HomeState {
  const HomeState({
    this.isLoading = false,
    this.dashboard,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentDashboard? dashboard;
  final String? errorMessage;
  final bool sessionExpired;

  HomeState copyWith({
    bool? isLoading,
    StudentDashboard? dashboard,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
