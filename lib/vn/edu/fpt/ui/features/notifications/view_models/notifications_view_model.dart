import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/notifications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/view_models/notifications_state.dart';

enum NotificationsLoadResult { success, failure, sessionExpired }

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel({
    required NotificationsRepository notificationsRepository,
  }) : _notificationsRepository = notificationsRepository;

  final NotificationsRepository _notificationsRepository;

  NotificationsState _state = const NotificationsState();
  NotificationsState get state => _state;

  Future<NotificationsLoadResult> loadNotifications() async {
    if (_state.isLoading) {
      return NotificationsLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _notificationsRepository.getNotifications();
    switch (result) {
      case Success(value: final notifications):
        _state = NotificationsState(notifications: notifications);
        notifyListeners();
        return NotificationsLoadResult.success;
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
            ? NotificationsLoadResult.sessionExpired
            : NotificationsLoadResult.failure;
    }
  }
}
