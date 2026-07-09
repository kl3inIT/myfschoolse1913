import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/notifications_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';

class NotificationsRepository {
  const NotificationsRepository({
    required NotificationsApiService notificationsApiService,
  }) : _notificationsApiService = notificationsApiService;

  final NotificationsApiService _notificationsApiService;

  Future<Result<StudentNotifications>> getNotifications() async {
    try {
      final dto = await _notificationsApiService.getNotifications();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải thông báo lúc này', cause: exception),
      );
    }
  }

  Future<Result<StudentNotificationDetail>> getNotification(String id) async {
    try {
      final dto = await _notificationsApiService.getNotification(id);
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure(
          'Không thể tải chi tiết thông báo lúc này',
          cause: exception,
        ),
      );
    }
  }
}
