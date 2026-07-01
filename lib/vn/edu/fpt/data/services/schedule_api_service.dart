import 'package:myfschoolse1913/vn/edu/fpt/data/models/student_schedule_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class ScheduleApiService {
  const ScheduleApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<StudentScheduleDto> getSchedule({DateTime? weekStart}) async {
    final json = await _apiClient.getJsonObject(
      '/api/students/me/schedule',
      queryParameters: {
        if (weekStart != null) 'weekStart': _formatDate(weekStart),
      },
    );
    return StudentScheduleDto.fromJson(json);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
