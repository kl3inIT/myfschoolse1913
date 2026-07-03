import 'package:myfschoolse1913/vn/edu/fpt/data/models/student_events_dto.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/authenticated_api_client.dart';

class EventsApiService {
  const EventsApiService(this._apiClient);

  final AuthenticatedApiClient _apiClient;

  Future<StudentEventsDto> getEvents() async {
    final json = await _apiClient.getJsonObject('/api/students/me/events');
    return StudentEventsDto.fromJson(json);
  }
}
