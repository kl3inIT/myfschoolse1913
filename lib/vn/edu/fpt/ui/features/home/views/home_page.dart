import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/dashboard_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_dashboard.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/home/view_models/home_view_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.dashboardRepository,
    required this.sessionController,
  });

  final DashboardRepository dashboardRepository;
  final AppSessionController sessionController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(dashboardRepository: widget.dashboardRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    final result = await _viewModel.loadDashboard();
    if (!mounted || result != HomeLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
    if (mounted) {
      context.go(AppRoutes.login);
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
                  final dashboard = state.dashboard;

                  return Column(
                    children: [
                      _DashboardHeader(dashboard: dashboard),
                      Expanded(
                        child: _DashboardBody(
                          dashboard: dashboard,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadDashboard,
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

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
        break;
      case 1:
        context.go(AppRoutes.schedule);
        break;
      case 3:
        context.go(AppRoutes.account);
        break;
    }
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.dashboard});

  final StudentDashboard? dashboard;

  @override
  Widget build(BuildContext context) {
    final roleLabel = dashboard?.student.role.label ?? 'Học sinh';

    return Container(
      height: 96,
      color: FptColors.orangeDeep,
      padding: const EdgeInsets.only(left: 24, top: 28, right: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Xin chào, $roleLabel',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Thông báo',
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.dashboard,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final StudentDashboard? dashboard;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedDashboard = dashboard;

    if (isLoading && loadedDashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedDashboard == null) {
      return _DashboardError(message: errorMessage, onRetry: onRetry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      children: [
        _StudentSummaryCard(student: loadedDashboard.student),
        const SizedBox(height: 34),
        const _SectionTitle('Tiện ích'),
        const SizedBox(height: 20),
        _FeatureGrid(shortcuts: loadedDashboard.shortcuts),
        const SizedBox(height: 28),
        const _SectionTitle('Hôm nay'),
        const SizedBox(height: 12),
        for (final item in loadedDashboard.todaySchedule) ...[
          _TodayScheduleTile(item: item),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}

class _StudentSummaryCard extends StatelessWidget {
  const _StudentSummaryCard({required this.student});

  final DashboardStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: FptColors.orangeDeep,
            foregroundColor: Colors.white,
            child: Text(
              student.initials,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.className,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.schoolYear,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _StatusChip(text: student.status),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: const Color(0xFF071126),
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.shortcuts});

  final List<DashboardShortcut> shortcuts;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shortcuts.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 88,
        mainAxisSpacing: 12,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final shortcut = shortcuts[index];
        return _FeatureCard(
          shortcut: shortcut,
          onTap: () => _openShortcut(context, shortcut.code),
        );
      },
    );
  }

  void _openShortcut(BuildContext context, String code) {
    switch (code) {
      case 'SEMESTER_GRADES':
        context.go(AppRoutes.semesterGrades);
      case 'SCHEDULE':
        context.go(AppRoutes.schedule);
      case 'EVENTS':
        context.go(AppRoutes.events);
    }
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.shortcut, required this.onTap});

  final DashboardShortcut shortcut;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FptColors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(shortcut.code), color: Colors.white, size: 24),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 20,
            child: Center(
              child: Text(
                shortcut.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1F2933),
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String code) {
    return switch (code) {
      'SEMESTER_GRADES' => Icons.fact_check_outlined,
      'SCHEDULE' => Icons.calendar_month_outlined,
      'EVENTS' => Icons.notifications_outlined,
      'APPLICATIONS' => Icons.description_outlined,
      'CLUBS' => Icons.groups_outlined,
      _ => Icons.apps_outlined,
    };
  }
}

class _TodayScheduleTile extends StatelessWidget {
  const _TodayScheduleTile({required this.item});

  final TodayScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.only(left: 12, right: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: FptColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FptColors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF071126),
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 52,
            child: Text(
              item.time,
              maxLines: 1,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FptColors.blue,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message ?? 'Không thể tải trang chủ',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: FptColors.textSecondary),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}
