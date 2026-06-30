import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_client.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/models/auth_session_dto.dart';

class AuthApiService {
  const AuthApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSessionDto> login({
    required String phoneNumber,
    required String password,
  }) async {
    final json = await _apiClient.postJsonObject(
      '/api/auth/login',
      body: {'phoneNumber': phoneNumber, 'password': password},
    );

    return AuthSessionDto.fromJson(json);
  }

  Future<AuthSessionDto> refresh(String refreshToken) async {
    final json = await _apiClient.postJsonObject(
      '/api/auth/refresh',
      body: {'refreshToken': refreshToken},
    );

    return AuthSessionDto.fromJson(json);
  }

  Future<void> logout(String refreshToken) {
    return _apiClient.postJsonVoid(
      '/api/auth/logout',
      body: {'refreshToken': refreshToken},
    );
  }
}
