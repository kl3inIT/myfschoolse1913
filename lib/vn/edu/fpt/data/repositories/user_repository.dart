import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/services/user_api_service.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/app_user.dart';

class UserRepository {
  const UserRepository({required UserApiService userApiService})
    : _userApiService = userApiService;

  final UserApiService _userApiService;

  Future<Result<AppUser>> me() async {
    try {
      final dto = await _userApiService.me();
      return Success(dto.toDomain());
    } on ApiException catch (exception) {
      return Failure(AppFailure(exception.message, cause: exception));
    } catch (exception) {
      return Failure(
        AppFailure('Không thể tải thông tin tài khoản', cause: exception),
      );
    }
  }
}
