import 'package:flutter/foundation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';

@immutable
class ApplicationsState {
  const ApplicationsState({
    this.isLoading = false,
    this.applications,
    this.selectedStatus = StudentApplicationStatus.pending,
    this.errorMessage,
    this.sessionExpired = false,
  });

  final bool isLoading;
  final StudentApplications? applications;
  final StudentApplicationStatus selectedStatus;
  final String? errorMessage;
  final bool sessionExpired;

  List<StudentApplication> get filteredApplications {
    final loadedApplications = applications;
    if (loadedApplications == null) {
      return const [];
    }
    return loadedApplications.applications
        .where((application) => application.status == selectedStatus)
        .toList(growable: false);
  }

  ApplicationsState copyWith({
    bool? isLoading,
    StudentApplications? applications,
    StudentApplicationStatus? selectedStatus,
    String? errorMessage,
    bool? sessionExpired,
    bool clearErrorMessage = false,
  }) {
    return ApplicationsState(
      isLoading: isLoading ?? this.isLoading,
      applications: applications ?? this.applications,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      sessionExpired: sessionExpired ?? this.sessionExpired,
    );
  }
}
