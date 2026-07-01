import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/grades_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/semester_grades.dart';

class GradesRepository {
  const GradesRepository({required GradesApiService gradesApiService})
    : _gradesApiService = gradesApiService;

  final GradesApiService _gradesApiService;

  Future<Result<SemesterGrades>> getSemesterGrades() async {
    try {
      final dto = await _gradesApiService.getSemesterGrades();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải điểm học kỳ lúc này', cause: exception),
      );
    }
  }
}
