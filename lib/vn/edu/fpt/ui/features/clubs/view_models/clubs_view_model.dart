import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/clubs_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/clubs/view_models/clubs_state.dart';

enum ClubsLoadResult { success, failure, sessionExpired }

class ClubsViewModel extends ChangeNotifier {
  ClubsViewModel({required ClubsRepository clubsRepository})
    : _clubsRepository = clubsRepository;

  final ClubsRepository _clubsRepository;

  ClubsState _state = const ClubsState();
  ClubsState get state => _state;

  Future<ClubsLoadResult> loadClubs() async {
    if (_state.isLoading) {
      return ClubsLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _clubsRepository.getClubs();
    switch (result) {
      case Success(value: final clubs):
        _state = ClubsState(clubs: clubs);
        notifyListeners();
        return ClubsLoadResult.success;
      case Failure(failure: final failure):
        final sessionExpired = _isUnauthorized(failure);
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
          sessionExpired: sessionExpired,
        );
        notifyListeners();
        return sessionExpired
            ? ClubsLoadResult.sessionExpired
            : ClubsLoadResult.failure;
    }
  }

  bool _isUnauthorized(AppFailure failure) {
    return failure.cause is ApiException &&
        (failure.cause! as ApiException).statusCode == 401;
  }
}
