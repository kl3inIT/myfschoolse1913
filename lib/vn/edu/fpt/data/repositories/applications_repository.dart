import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/applications_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';

class ApplicationsRepository {
  const ApplicationsRepository({
    required ApplicationsApiService applicationsApiService,
  }) : _applicationsApiService = applicationsApiService;

  final ApplicationsApiService _applicationsApiService;

  Future<Result<StudentApplications>> getApplications() async {
    try {
      final dto = await _applicationsApiService.getApplications();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải danh sách đơn từ', cause: exception),
      );
    }
  }

  Future<Result<StudentApplication>> createApplication({
    required StudentApplicationType type,
    required DateTime targetDate,
    required String reason,
    required String details,
    String? requestedTime,
  }) async {
    try {
      final dto = await _applicationsApiService.createApplication(
        type: type,
        targetDate: targetDate,
        reason: reason,
        details: details,
        requestedTime: requestedTime,
      );
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(AppFailure('Không thể gửi đơn lúc này', cause: exception));
    }
  }
}
