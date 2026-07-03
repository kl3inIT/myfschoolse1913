import 'package:myfschoolse1913/vn/edu/fpt/data/models/student_applications_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';

class ApplicationsApiService {
  const ApplicationsApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<StudentApplicationsDto> getApplications() async {
    final json = await _apiClient.getJsonObject(
      '/api/students/me/applications',
    );
    return StudentApplicationsDto.fromJson(json);
  }

  Future<StudentApplicationDto> createApplication({
    required StudentApplicationType type,
    required DateTime targetDate,
    required String reason,
    required String details,
    String? requestedTime,
  }) async {
    final body = <String, Object?>{
      'type': type.wireValue,
      'targetDate': _formatDate(targetDate),
      'reason': reason,
      'details': details,
    };
    if (requestedTime != null) {
      body['requestedTime'] = requestedTime;
    }

    final json = await _apiClient.postJsonObject(
      '/api/students/me/applications',
      body: body,
    );
    return StudentApplicationDto.fromJson(json);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
