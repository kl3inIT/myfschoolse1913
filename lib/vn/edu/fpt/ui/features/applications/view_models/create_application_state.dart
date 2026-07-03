import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';

@immutable
class CreateApplicationState {
  const CreateApplicationState({
    this.type = StudentApplicationType.absence,
    this.targetDate,
    this.requestedTime,
    this.isSubmitting = false,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final StudentApplicationType type;
  final DateTime? targetDate;
  final String? requestedTime;
  final bool isSubmitting;
  final String? errorMessage;
  final bool sessionExpired;

  CreateApplicationState copyWith({
    StudentApplicationType? type,
    DateTime? targetDate,
    String? requestedTime,
    bool? isSubmitting,
    String? errorMessage,
    bool? sessionExpired,
    bool clearRequestedTime = false,
    bool clearErrorMessage = false,
  }) {
    return CreateApplicationState(
      type: type ?? this.type,
      targetDate: targetDate ?? this.targetDate,
      requestedTime: clearRequestedTime
          ? null
          : requestedTime ?? this.requestedTime,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
