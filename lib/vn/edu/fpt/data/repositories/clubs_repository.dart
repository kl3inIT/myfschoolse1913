import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/clubs_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';

class ClubsRepository {
  const ClubsRepository({required ClubsApiService clubsApiService})
    : _clubsApiService = clubsApiService;

  final ClubsApiService _clubsApiService;

  Future<Result<StudentClubs>> getClubs() async {
    try {
      final dto = await _clubsApiService.getClubs();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải danh sách câu lạc bộ', cause: exception),
      );
    }
  }

  Future<Result<StudentClub>> registerClub(String clubId) async {
    try {
      final dto = await _clubsApiService.registerClub(clubId);
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(AppFailure('Không thể gửi đăng ký CLB', cause: exception));
    }
  }
}
