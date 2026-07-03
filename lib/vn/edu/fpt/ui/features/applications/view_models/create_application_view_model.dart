import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/network/api_exception.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/applications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/view_models/create_application_state.dart';

enum CreateApplicationResult { success, failure, sessionExpired }

class CreateApplicationViewModel extends ChangeNotifier {
  CreateApplicationViewModel({
    required ApplicationsRepository applicationsRepository,
  }) : _applicationsRepository = applicationsRepository;

  final ApplicationsRepository _applicationsRepository;

  final reasonController = TextEditingController();
  final detailsController = TextEditingController();

  CreateApplicationState _state = const CreateApplicationState();
  CreateApplicationState get state => _state;

  void setType(StudentApplicationType type) {
    _state = _state.copyWith(
      type: type,
      clearRequestedTime: !type.requiresTime,
      clearErrorMessage: true,
    );
    notifyListeners();
  }

  void setTargetDate(DateTime date) {
    _state = _state.copyWith(targetDate: date, clearErrorMessage: true);
    notifyListeners();
  }

  void setRequestedTime(TimeOfDay timeOfDay) {
    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    _state = _state.copyWith(
      requestedTime: '$hour:$minute',
      clearErrorMessage: true,
    );
    notifyListeners();
  }

  Future<CreateApplicationResult> submit() async {
    if (_state.isSubmitting) {
      return CreateApplicationResult.failure;
    }

    final targetDate = _state.targetDate;
    if (targetDate == null) {
      _state = _state.copyWith(errorMessage: 'Vui lòng chọn ngày áp dụng');
      notifyListeners();
      return CreateApplicationResult.failure;
    }

    if (_state.type.requiresTime && _state.requestedTime == null) {
      _state = _state.copyWith(errorMessage: 'Vui lòng chọn giờ áp dụng');
      notifyListeners();
      return CreateApplicationResult.failure;
    }

    final reason = reasonController.text.trim();
    if (reason.isEmpty) {
      _state = _state.copyWith(errorMessage: 'Vui lòng nhập lý do');
      notifyListeners();
      return CreateApplicationResult.failure;
    }

    _state = _state.copyWith(
      isSubmitting: true,
      sessionExpired: false,
      clearErrorMessage: true,
    );
    notifyListeners();

    final result = await _applicationsRepository.createApplication(
      type: _state.type,
      targetDate: targetDate,
      requestedTime: _state.requestedTime,
      reason: reason,
      details: detailsController.text.trim(),
    );
    switch (result) {
      case Success():
        _state = _state.copyWith(isSubmitting: false, clearErrorMessage: true);
        notifyListeners();
        return CreateApplicationResult.success;
      case Failure(failure: final failure):
        final sessionExpired =
            failure.cause is ApiException &&
            (failure.cause! as ApiException).statusCode == 401;
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
          sessionExpired: sessionExpired,
        );
        notifyListeners();
        return sessionExpired
            ? CreateApplicationResult.sessionExpired
            : CreateApplicationResult.failure;
    }
  }

  @override
  void dispose() {
    reasonController.dispose();
    detailsController.dispose();
    super.dispose();
  }
}
