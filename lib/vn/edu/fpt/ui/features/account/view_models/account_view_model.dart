import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/user_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/app_user.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/account/view_models/account_state.dart';

enum AccountLoadResult { success, failure, sessionExpired }

class AccountViewModel extends ChangeNotifier {
  AccountViewModel({
    required UserRepository userRepository,
    required AppSessionController sessionController,
    AppUser? initialUser,
  }) : _userRepository = userRepository,
       _sessionController = sessionController,
       _state = AccountState(user: initialUser);

  final UserRepository _userRepository;
  final AppSessionController _sessionController;

  AccountState _state;
  AccountState get state => _state;

  Future<AccountLoadResult> loadAccount() async {
    if (_state.isLoading) {
      return AccountLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _userRepository.me();
    switch (result) {
      case Success(value: final user):
        _state = AccountState(user: user);
        notifyListeners();
        return AccountLoadResult.success;
      case Failure(failure: final failure):
        final sessionExpired =
            failure.cause is ApiException &&
            (failure.cause! as ApiException).statusCode == 401;
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          sessionExpired: sessionExpired,
        );
        notifyListeners();
        return sessionExpired
            ? AccountLoadResult.sessionExpired
            : AccountLoadResult.failure;
    }
  }

  Future<void> logout() async {
    if (_state.isLoggingOut) {
      return;
    }

    _state = _state.copyWith(isLoggingOut: true, clearErrorMessage: true);
    notifyListeners();

    await _sessionController.logout();
  }
}
