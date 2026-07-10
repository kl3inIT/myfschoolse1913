import 'package:flutter/foundation.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/assistant_api_service.dart';

/// [LlmProvider] backed by the school backend: each turn POSTs the message to
/// `/api/students/me/assistant/chat` (JWT attached by the api client) and
/// relays the SSE text deltas into the chat view. Conversation memory lives on
/// the server, so this provider only mirrors the on-screen transcript.
class SchoolAssistantProvider extends LlmProvider with ChangeNotifier {
  SchoolAssistantProvider({required AssistantApiService assistantApiService})
    : _assistantApiService = assistantApiService;

  final AssistantApiService _assistantApiService;
  final List<ChatMessage> _history = [];

  @override
  Stream<String> generateStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) {
    return _stream(prompt);
  }

  @override
  Stream<String> sendMessageStream(
    String prompt, {
    Iterable<Attachment> attachments = const [],
  }) async* {
    final userMessage = ChatMessage.user(prompt, attachments);
    final llmMessage = ChatMessage.llm();
    _history.addAll([userMessage, llmMessage]);

    yield* _stream(prompt).map((chunk) {
      llmMessage.append(chunk);
      return chunk;
    });

    notifyListeners();
  }

  Stream<String> _stream(String prompt) async* {
    try {
      yield* _assistantApiService.streamChat(prompt);
    } on ApiException catch (exception) {
      throw LlmFailureException(exception.message);
    }
  }

  @override
  Iterable<ChatMessage> get history => _history;

  @override
  set history(Iterable<ChatMessage> history) {
    _history.clear();
    _history.addAll(history);
    notifyListeners();
  }
}
