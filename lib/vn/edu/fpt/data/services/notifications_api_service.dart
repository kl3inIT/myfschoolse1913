import 'package:myfschoolse1913/vn/edu/fpt/data/models/student_notifications_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class NotificationsApiService {
  const NotificationsApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<StudentNotificationsDto> getNotifications() async {
    final json = await _apiClient.getJsonObject(
      '/api/students/me/notifications',
    );
    return StudentNotificationsDto.fromJson(json);
  }
}
