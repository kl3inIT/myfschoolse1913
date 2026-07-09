import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/notifications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/view_models/notification_detail_state.dart';

enum NotificationDetailLoadResult { success, failure, sessionExpired }

class NotificationDetailViewModel extends ChangeNotifier {
  NotificationDetailViewModel({
    required NotificationsRepository notificationsRepository,
    required String notificationId,
  }) : _notificationsRepository = notificationsRepository,
       _notificationId = notificationId;

  final NotificationsRepository _notificationsRepository;
  final String _notificationId;

  NotificationDetailState _state = const NotificationDetailState();
  NotificationDetailState get state => _state;

  Future<NotificationDetailLoadResult> loadNotification() async {
    if (_state.isLoading) {
      return NotificationDetailLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _notificationsRepository.getNotification(
      _notificationId,
    );
    switch (result) {
      case Success(value: final notification):
        _state = NotificationDetailState(notification: notification);
        notifyListeners();
        return NotificationDetailLoadResult.success;
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
            ? NotificationDetailLoadResult.sessionExpired
            : NotificationDetailLoadResult.failure;
    }
  }
}
