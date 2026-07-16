import 'package:myfschoolse1913/vn/edu/fpt/data/models/parent_workspace_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class ParentApiService {
  const ParentApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<ParentWorkspaceDto> getWorkspace({String? studentId}) async {
    final json = await _apiClient.getJsonObject(
      '/api/parents/me/workspace',
      queryParameters: studentId == null ? null : {'studentId': studentId},
    );
    return ParentWorkspaceDto.fromJson(json);
  }

  Future<void> createApplication({
    required String studentId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? requestedTime,
    String? details,
  }) async {
    await _apiClient.postJsonObject(
      '/api/parents/me/children/$studentId/applications',
      body: {
        'type': type,
        'startDate': _date(startDate),
        'endDate': _date(endDate),
        'requestedTime': requestedTime,
        'reason': reason,
        'details': details,
      },
    );
  }

  String _date(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
