import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/clubs_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/clubs/view_models/club_registration_state.dart';

enum ClubRegistrationResult { success, failure, sessionExpired }

class ClubRegistrationViewModel extends ChangeNotifier {
  ClubRegistrationViewModel({
    required ClubsRepository clubsRepository,
    required StudentClub club,
  }) : _clubsRepository = clubsRepository,
       _state = ClubRegistrationState(club: club);

  final ClubsRepository _clubsRepository;

  ClubRegistrationState _state;
  ClubRegistrationState get state => _state;

  Future<ClubRegistrationResult> submit() async {
    if (_state.isSubmitting || !_state.club.canRegister) {
      return ClubRegistrationResult.failure;
    }

    _state = _state.copyWith(
      isSubmitting: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _clubsRepository.registerClub(_state.club.id);
    switch (result) {
      case Success(value: final club):
        _state = _state.copyWith(
          club: club,
          isSubmitting: false,
          clearErrorMessage: true,
        );
        notifyListeners();
        return ClubRegistrationResult.success;
      case Failure(failure: final failure):
        final sessionExpired = _isUnauthorized(failure);
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          sessionExpired: sessionExpired,
        );
        notifyListeners();
        return sessionExpired
            ? ClubRegistrationResult.sessionExpired
            : ClubRegistrationResult.failure;
    }
  }

  bool _isUnauthorized(AppFailure failure) {
    return failure.cause is ApiException &&
        (failure.cause! as ApiException).statusCode == 401;
  }
}
