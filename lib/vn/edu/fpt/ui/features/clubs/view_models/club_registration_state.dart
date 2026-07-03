import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';

@immutable
class ClubRegistrationState {
  const ClubRegistrationState({
    required this.club,
    this.isSubmitting = false,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final StudentClub club;
  final bool isSubmitting;
  final String? errorMessage;
  final bool sessionExpired;

  ClubRegistrationState copyWith({
    StudentClub? club,
    bool? isSubmitting,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return ClubRegistrationState(
      club: club ?? this.club,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
