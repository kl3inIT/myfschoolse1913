import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/schedule_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_schedule.dart';

class ScheduleRepository {
  const ScheduleRepository({required ScheduleApiService scheduleApiService})
    : _scheduleApiService = scheduleApiService;

  final ScheduleApiService _scheduleApiService;

  Future<Result<StudentSchedule>> getSchedule({DateTime? weekStart}) async {
    try {
      final dto = await _scheduleApiService.getSchedule(weekStart: weekStart);
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải lịch học lúc này', cause: exception),
      );
    }
  }
}
