import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';

class ApiClient {
  const ApiClient({required Uri baseUri, required http.Client client})
    : _baseUri = baseUri,
      _client = client;

  final Uri _baseUri;
  final http.Client _client;

  Future<Map<String, Object?>> getJsonObject(
    String path, {
    String? bearerToken,
    Map<String, String>? queryParameters,
  }) async {
    final response = await _client.get(
      _resolve(path, queryParameters: queryParameters),
      headers: _headers(bearerToken),
    );

    _throwIfFailed(response);
    return _decodeObject(response.body);
  }

  Future<Map<String, Object?>> postJsonObject(
    String path, {
    Map<String, Object?>? body,
    String? bearerToken,
  }) async {
    final response = await _client.post(
      _resolve(path),
      headers: _headers(bearerToken),
      body: jsonEncode(body ?? const <String, Object?>{}),
    );

    _throwIfFailed(response);
    return _decodeObject(response.body);
  }

  Future<void> postJsonVoid(
    String path, {
    Map<String, Object?>? body,
    String? bearerToken,
  }) async {
    final response = await _client.post(
      _resolve(path),
      headers: _headers(bearerToken),
      body: jsonEncode(body ?? const <String, Object?>{}),
    );

    _throwIfFailed(response);
  }

  Map<String, Object?> _decodeObject(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, Object?>) {
      return decoded;
    }

    throw const ApiException(
      statusCode: 500,
      message: 'Phản hồi máy chủ không hợp lệ',
    );
  }

  Uri _resolve(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return _baseUri.replace(
      pathSegments: [..._baseUri.pathSegments, ...normalizedPath.split('/')],
      queryParameters: queryParameters,
    );
  }

  Map<String, String> _headers(String? bearerToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (bearerToken != null) 'Authorization': 'Bearer $bearerToken',
    };
  }

  void _throwIfFailed(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: _extractMessage(response.body),
    );
  }

  String _extractMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded case {'message': final String message}) {
        return _localizeServerMessage(message);
      }
      if (decoded case {'error': final String error}) {
        return _localizeServerMessage(error);
      }
    } catch (_) {
      // Fall through to a user-safe generic message.
    }

    return 'Không thể kết nối tới máy chủ';
  }

  String _localizeServerMessage(String message) {
    return switch (message) {
      'Invalid phone number, password, or refresh token' =>
        'Thông tin đăng nhập không hợp lệ',
      'phoneNumber must contain 9 to 15 digits' =>
        'Số điện thoại phải gồm 9 đến 15 chữ số',
      'otp must contain 6 digits' => 'Mã xác thực phải gồm 6 chữ số',
      'newPassword must contain 8 to 72 characters' =>
        'Mật khẩu mới phải từ 8 đến 72 ký tự',
      'Validation failed' => 'Dữ liệu không hợp lệ',
      'Session is no longer valid' ||
      'Student session is no longer valid' ||
      'Unauthorized' => 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại',
      _ => message,
    };
  }
}
