import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/dashboard_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_dashboard.dart';

class DashboardRepository {
  const DashboardRepository({required DashboardApiService dashboardApiService})
    : _dashboardApiService = dashboardApiService;

  final DashboardApiService _dashboardApiService;

  Future<Result<StudentDashboard>> getStudentDashboard() async {
    try {
      final dto = await _dashboardApiService.getStudentDashboard();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải trang chủ lúc này', cause: exception),
      );
    }
  }
}
