import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/events_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_events.dart';

class EventsRepository {
  const EventsRepository({required EventsApiService eventsApiService})
    : _eventsApiService = eventsApiService;

  final EventsApiService _eventsApiService;

  Future<Result<StudentEvents>> getEvents() async {
    try {
      final dto = await _eventsApiService.getEvents();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải sự kiện lúc này', cause: exception),
      );
    }
  }
}
