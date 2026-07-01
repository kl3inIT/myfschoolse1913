import 'package:myfschoolse1913/vn/edu/fpt/data/models/app_user_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class UserApiService {
  const UserApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<AppUserDto> me() async {
    final json = await _apiClient.getJsonObject('/api/me');
    return AppUserDto.fromJson(json);
  }
}
