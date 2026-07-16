import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/parent_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/parent_workspace.dart';

class ParentRepository {
  const ParentRepository({required ParentApiService parentApiService})
    : _parentApiService = parentApiService;

  final ParentApiService _parentApiService;

  Future<Result<ParentWorkspace>> getWorkspace({String? studentId}) async {
    try {
      final dto = await _parentApiService.getWorkspace(studentId: studentId);
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải thông tin phụ huynh', cause: exception),
      );
    }
  }

  Future<Result<void>> createApplication({
    required String studentId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? requestedTime,
    String? details,
  }) async {
    try {
      await _parentApiService.createApplication(
        studentId: studentId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        requestedTime: requestedTime,
        details: details,
      );
      return const Success(null);
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(AppFailure('Không thể gửi đơn', cause: exception));
    }
  }
}
