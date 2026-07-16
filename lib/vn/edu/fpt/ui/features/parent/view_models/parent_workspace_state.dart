import 'package:myfschoolse1913/vn/edu/fpt/domain/models/parent_workspace.dart';

class ParentWorkspaceState {
  const ParentWorkspaceState({
    this.workspace,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final ParentWorkspace? workspace;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  ParentWorkspaceState copyWith({
    ParentWorkspace? workspace,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ParentWorkspaceState(
      workspace: workspace ?? this.workspace,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
