import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/auth_session.dart';

abstract interface class TokenStorage {
  Future<void> saveSession(AuthSession session);

  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> clear();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'auth.accessToken';
  static const _refreshTokenKey = 'auth.refreshToken';
  static const _expiresAtKey = 'auth.expiresAt';

  final FlutterSecureStorage _storage;
  String? _accessToken;
  String? _refreshToken;

  @override
  Future<void> saveSession(AuthSession session) async {
    _accessToken = session.accessToken;
    _refreshToken = session.refreshToken;
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: session.accessToken),
      _storage.write(key: _refreshTokenKey, value: session.refreshToken),
      _storage.write(
        key: _expiresAtKey,
        value: session.expiresAt.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<String?> readAccessToken() async {
    if (_accessToken != null) {
      return _accessToken;
    }

    _accessToken = await _storage.read(key: _accessTokenKey);
    return _accessToken;
  }

  @override
  Future<String?> readRefreshToken() async {
    if (_refreshToken != null) {
      return _refreshToken;
    }

    _refreshToken = await _storage.read(key: _refreshTokenKey);
    return _refreshToken;
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    _refreshToken = null;
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _expiresAtKey),
    ]);
  }
}
