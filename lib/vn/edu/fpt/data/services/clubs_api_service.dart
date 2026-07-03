import 'package:myfschoolse1913/vn/edu/fpt/data/models/student_clubs_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class ClubsApiService {
  const ClubsApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<StudentClubsDto> getClubs() async {
    final json = await _apiClient.getJsonObject('/api/students/me/clubs');
    return StudentClubsDto.fromJson(json);
  }

  Future<StudentClubDto> registerClub(String clubId) async {
    final json = await _apiClient.postJsonObject(
      '/api/students/me/clubs/$clubId/registrations',
    );
    return StudentClubDto.fromJson(json);
  }
}
