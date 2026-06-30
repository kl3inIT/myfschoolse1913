import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/auth_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/token_storage.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/auth_session.dart';

class AuthRepository {
  const AuthRepository({
    required AuthApiService authApiService,
    required TokenStorage tokenStorage,
  }) : _authApiService = authApiService,
       _tokenStorage = tokenStorage;

  final AuthApiService _authApiService;
  final TokenStorage _tokenStorage;

  Future<Result<AuthSession>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final dto = await _authApiService.login(
        phoneNumber: phoneNumber,
        password: password,
      );
      final session = dto.toDomain(DateTime.now());
      await _tokenStorage.saveSession(session);
      return Success(session);
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể đăng nhập lúc này', cause: exception),
      );
    }
  }

  Future<Result<AuthSession>> refresh() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null) {
        return const Failure(AppFailure('Phiên đăng nhập đã hết hạn'));
      }

      final dto = await _authApiService.refresh(refreshToken);
      final session = dto.toDomain(DateTime.now());
      await _tokenStorage.saveSession(session);
      return Success(session);
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể làm mới phiên đăng nhập', cause: exception),
      );
    }
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _authApiService.logout(refreshToken);
      } on ApiException {
        // Local logout should still clear tokens when the server is unreachable.
      }
    }

    await _tokenStorage.clear();
  }

  Future<Result<void>> requestPasswordReset({
    required String phoneNumber,
  }) async {
    try {
      await _authApiService.requestPasswordReset(phoneNumber: phoneNumber);
      return const Success(null);
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể gửi mã xác thực lúc này', cause: exception),
      );
    }
  }
}
