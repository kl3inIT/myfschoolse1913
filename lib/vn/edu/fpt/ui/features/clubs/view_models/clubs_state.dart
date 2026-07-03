import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';

@immutable
class ClubsState {
  const ClubsState({
    this.isLoading = false,
    this.clubs,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentClubs? clubs;
  final String? errorMessage;
  final bool sessionExpired;

  ClubsState copyWith({
    bool? isLoading,
    StudentClubs? clubs,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return ClubsState(
      isLoading: isLoading ?? this.isLoading,
      clubs: clubs ?? this.clubs,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
