import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';

@immutable
class NotificationsState {
  const NotificationsState({
    this.isLoading = false,
    this.notifications,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentNotifications? notifications;
  final String? errorMessage;
  final bool sessionExpired;

  NotificationsState copyWith({
    bool? isLoading,
    StudentNotifications? notifications,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return NotificationsState(
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
