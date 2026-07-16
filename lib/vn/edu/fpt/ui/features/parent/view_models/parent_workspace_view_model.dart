import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/result/result.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/parent_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/parent/view_models/parent_workspace_state.dart';

class ParentWorkspaceViewModel extends ChangeNotifier {
  ParentWorkspaceViewModel({required ParentRepository parentRepository})
    : _parentRepository = parentRepository;

  final ParentRepository _parentRepository;
  ParentWorkspaceState _state = const ParentWorkspaceState();

  ParentWorkspaceState get state => _state;

  Future<void> load({String? studentId}) async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();
    final result = await _parentRepository.getWorkspace(studentId: studentId);
    switch (result) {
      case Success(value: final workspace):
        _state = ParentWorkspaceState(workspace: workspace);
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
    }
    notifyListeners();
  }

  Future<String?> createApplication({
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
    String? requestedTime,
    String? details,
  }) async {
    final studentId = _state.workspace?.selectedChild?.child.id;
    if (studentId == null) return 'Vui lòng chọn học sinh';
    _state = _state.copyWith(isSubmitting: true, clearError: true);
    notifyListeners();
    final result = await _parentRepository.createApplication(
      studentId: studentId,
      type: type,
      startDate: startDate,
      endDate: endDate,
      reason: reason,
      requestedTime: requestedTime,
      details: details,
    );
    switch (result) {
      case Success():
        await load(studentId: studentId);
        return null;
      case Failure(failure: final failure):
        _state = _state.copyWith(
          isSubmitting: false,
          errorMessage: failure.message,
        );
        notifyListeners();
        return failure.message;
    }
  }
}
