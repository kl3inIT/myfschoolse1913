import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';

@immutable
class NotificationDetailState {
  const NotificationDetailState({
    this.isLoading = false,
    this.notification,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentNotificationDetail? notification;
  final String? errorMessage;
  final bool sessionExpired;

  NotificationDetailState copyWith({
    bool? isLoading,
    StudentNotificationDetail? notification,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return NotificationDetailState(
      isLoading: isLoading ?? this.isLoading,
      notification: notification ?? this.notification,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
