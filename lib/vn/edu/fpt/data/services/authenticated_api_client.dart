import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_client.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/auth_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/token_storage.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/auth_session.dart';

class AuthenticatedApiClient {
  const AuthenticatedApiClient({
    required ApiClient apiClient,
    required AuthApiService authApiService,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _authApiService = authApiService,
       _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final AuthApiService _authApiService;
  final TokenStorage _tokenStorage;

  Future<Map<String, Object?>> getJsonObject(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _sendWithAuth((accessToken) {
      return _apiClient.getJsonObject(
        path,
        bearerToken: accessToken,
        queryParameters: queryParameters,
      );
    });
  }

  Future<Map<String, Object?>> postJsonObject(
    String path, {
    Map<String, Object?>? body,
  }) {
    return _sendWithAuth((accessToken) {
      return _apiClient.postJsonObject(
        path,
        body: body,
        bearerToken: accessToken,
      );
    });
  }

  Future<void> postJsonVoid(String path, {Map<String, Object?>? body}) {
    return _sendWithAuth((accessToken) {
      return _apiClient.postJsonVoid(
        path,
        body: body,
        bearerToken: accessToken,
      );
    });
  }

  Future<T> _sendWithAuth<T>(
    Future<T> Function(String accessToken) send,
  ) async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken == null) {
      throw const ApiException(
        statusCode: 401,
        message: 'Phiên đăng nhập đã hết hạn',
      );
    }

    try {
      return await send(accessToken);
    } on ApiException catch (exception) {
      if (exception.statusCode != 401) {
        rethrow;
      }

      final refreshedSession = await _refreshSession();
      return send(refreshedSession.accessToken);
    }
  }

  Future<AuthSession> _refreshSession() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) {
      throw const ApiException(
        statusCode: 401,
        message: 'Phiên đăng nhập đã hết hạn',
      );
    }

    try {
      final dto = await _authApiService.refresh(refreshToken);
      final session = dto.toDomain(DateTime.now());
      await _tokenStorage.saveSession(session);
      return session;
    } catch (exception) {
      await _tokenStorage.clear();
      throw ApiException(
        statusCode: 401,
        message: 'Phiên đăng nhập đã hết hạn',
        cause: exception,
      );
    }
  }
}
