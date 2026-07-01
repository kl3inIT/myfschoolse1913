import 'package:myfschoolse1913/vn/edu/fpt/data/models/student_dashboard_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class DashboardApiService {
  const DashboardApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<StudentDashboardDto> getStudentDashboard() async {
    final json = await _apiClient.getJsonObject('/api/students/me/dashboard');
    return StudentDashboardDto.fromJson(json);
  }
}
