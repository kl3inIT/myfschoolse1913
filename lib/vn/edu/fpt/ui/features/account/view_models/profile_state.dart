import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_dashboard.dart';

@immutable
class ProfileState {
  const ProfileState({
    this.student,
    this.isLoading = false,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final DashboardStudent? student;
  final bool isLoading;
  final String? errorMessage;
  final bool sessionExpired;

  ProfileState copyWith({
    DashboardStudent? student,
    bool? isLoading,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return ProfileState(
      student: student ?? this.student,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
