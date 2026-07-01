import 'package:myfschoolse1913/vn/edu/fpt/data/models/semester_grades_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class GradesApiService {
  const GradesApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<SemesterGradesDto> getSemesterGrades() async {
    final json = await _apiClient.getJsonObject(
      '/api/students/me/semester-grades',
    );
    return SemesterGradesDto.fromJson(json);
  }
}
