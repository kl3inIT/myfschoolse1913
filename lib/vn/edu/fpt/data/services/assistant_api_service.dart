import 'dart:convert';

import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class AssistantApiService {
  const AssistantApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  /// Sends one chat turn and yields assistant text deltas as they stream in.
  /// The server keeps the conversation memory, so only the new message rides.
  Stream<String> streamChat(String message) async* {
    final events = _apiClient.postEventStream(
      '/api/students/me/assistant/chat',
      body: {'message': message},
    );

    await for (final data in events) {
      final Object? decoded;
      try {
        decoded = jsonDecode(data);
      } on FormatException {
        continue;
      }

      if (decoded case {'text': final String text}) {
        yield text;
      } else if (decoded case {'error': final String error}) {
        throw ApiException(statusCode: 502, message: error);
      }
    }
  }
}
