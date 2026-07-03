import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/applications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/view_models/applications_state.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/view_models/applications_view_model.dart';

class ApplicationsPage extends StatefulWidget {
  const ApplicationsPage({
    super.key,
    required this.applicationsRepository,
    required this.sessionController,
  });

  final ApplicationsRepository applicationsRepository;
  final AppSessionController sessionController;

  @override
  State<ApplicationsPage> createState() => _ApplicationsPageState();
}

class _ApplicationsPageState extends State<ApplicationsPage> {
  late final ApplicationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ApplicationsViewModel(
      applicationsRepository: widget.applicationsRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadApplications() async {
    final result = await _viewModel.loadApplications();
    if (!mounted || result != ApplicationsLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _goHome() {
    context.go(AppRoutes.home);
  }

  void _createApplication() {
    context.go(AppRoutes.createApplication);
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        _goHome();
        break;
      case 1:
        context.go(AppRoutes.schedule);
        break;
      case 3:
        context.go(AppRoutes.account);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FptColors.field,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: ColoredBox(
              color: Colors.white,
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final state = _viewModel.state;

                  return Column(
                    children: [
                      StudentTopAppBar(title: 'Đơn từ', onBack: _goHome),
                      Expanded(
                        child: _ApplicationsBody(
                          state: state,
                          onCreateApplication: _createApplication,
                          onStatusSelected: _viewModel.selectStatus,
                          onRetry: _loadApplications,
                        ),
                      ),
                      StudentBottomNavigation(
                        currentIndex: 0,
                        onDestinationSelected: _onDestinationSelected,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationsBody extends StatelessWidget {
  const _ApplicationsBody({
    required this.state,
    required this.onCreateApplication,
    required this.onStatusSelected,
    required this.onRetry,
  });

  final ApplicationsState state;
  final VoidCallback onCreateApplication;
  final ValueChanged<StudentApplicationStatus> onStatusSelected;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.applications == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.applications == null) {
      return _ApplicationsError(message: state.errorMessage, onRetry: onRetry);
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          FilledButton.icon(
            onPressed: onCreateApplication,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Tạo đơn mới'),
          ),
          const SizedBox(height: 24),
          _ApplicationTabs(
            selectedStatus: state.selectedStatus,
            onStatusSelected: onStatusSelected,
          ),
          const SizedBox(height: 28),
          if (state.filteredApplications.isEmpty)
            _ApplicationsEmpty(status: state.selectedStatus)
          else
            for (final application in state.filteredApplications) ...[
              _ApplicationTile(application: application),
              const SizedBox(height: 10),
            ],
          if (state.selectedStatus == StudentApplicationStatus.pending) ...[
            const SizedBox(height: 28),
            Text(
              'Loại đơn phổ biến',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: FptColors.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const _QuickTypeChips(),
          ],
        ],
      ),
    );
  }
}

class _ApplicationTabs extends StatelessWidget {
  const _ApplicationTabs({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final StudentApplicationStatus selectedStatus;
  final ValueChanged<StudentApplicationStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final status in StudentApplicationStatus.values) ...[
          _ApplicationTab(
            status: status,
            selected: status == selectedStatus,
            onTap: () => onStatusSelected(status),
          ),
          const SizedBox(width: 22),
        ],
      ],
    );
  }
}

class _ApplicationTab extends StatelessWidget {
  const _ApplicationTab({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final StudentApplicationStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? FptColors.orangeDeep : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              status.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: selected
                    ? FptColors.orangeDeep
                    : FptColors.textSecondary,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ApplicationTile extends StatelessWidget {
  const _ApplicationTile({required this.application});

  final StudentApplication application;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 68),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FptColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  application.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  application.summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusChip(status: application.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final StudentApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _statusForeground(status),
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class _QuickTypeChips extends StatelessWidget {
  const _QuickTypeChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final type in StudentApplicationType.values)
          Chip(
            label: Text(type.label),
            backgroundColor: const Color(0xFFD1FAE5),
            side: BorderSide.none,
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF047857),
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }
}

class _ApplicationsEmpty extends StatelessWidget {
  const _ApplicationsEmpty({required this.status});

  final StudentApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          _message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: FptColors.textSecondary,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  String get _message {
    return switch (status) {
      StudentApplicationStatus.pending => 'Chưa có đơn đang xử lý',
      StudentApplicationStatus.approved => 'Chưa có đơn đã duyệt',
      StudentApplicationStatus.rejected => 'Chưa có đơn bị từ chối',
    };
  }
}

class _ApplicationsError extends StatelessWidget {
  const _ApplicationsError({required this.message, required this.onRetry});

  final String? message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Không thể tải danh sách đơn từ',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: FptColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                onRetry();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusBackground(StudentApplicationStatus status) {
  return switch (status) {
    StudentApplicationStatus.pending => const Color(0xFFFEF3C7),
    StudentApplicationStatus.approved => const Color(0xFFD1FAE5),
    StudentApplicationStatus.rejected => const Color(0xFFFEE2E2),
  };
}

Color _statusForeground(StudentApplicationStatus status) {
  return switch (status) {
    StudentApplicationStatus.pending => const Color(0xFF92400E),
    StudentApplicationStatus.approved => const Color(0xFF047857),
    StudentApplicationStatus.rejected => const Color(0xFFB91C1C),
  };
}
