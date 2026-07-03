import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/events_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/events/view_models/events_state.dart';

enum EventsLoadResult { success, failure, sessionExpired }

class EventsViewModel extends ChangeNotifier {
  EventsViewModel({required EventsRepository eventsRepository})
    : _eventsRepository = eventsRepository;

  final EventsRepository _eventsRepository;

  EventsState _state = const EventsState();
  EventsState get state => _state;

  Future<EventsLoadResult> loadEvents() async {
    if (_state.isLoading) {
      return EventsLoadResult.failure;
    }

    _state = _state.copyWith(
      isLoading: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _eventsRepository.getEvents();
    switch (result) {
      case Success(value: final events):
        _state = EventsState(events: events);
        notifyListeners();
        return EventsLoadResult.success;
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
            ? EventsLoadResult.sessionExpired
            : EventsLoadResult.failure;
    }
  }
}
