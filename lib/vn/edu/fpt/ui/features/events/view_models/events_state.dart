import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_events.dart';

@immutable
class EventsState {
  const EventsState({
    this.isLoading = false,
    this.events,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentEvents? events;
  final String? errorMessage;
  final bool sessionExpired;

  EventsState copyWith({
    bool? isLoading,
    StudentEvents? events,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return EventsState(
      isLoading: isLoading ?? this.isLoading,
      events: events ?? this.events,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
