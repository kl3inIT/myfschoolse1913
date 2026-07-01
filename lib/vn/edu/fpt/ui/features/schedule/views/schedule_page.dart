import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/schedule_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_schedule.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/schedule/view_models/schedule_view_model.dart';

enum _ScheduleViewMode { today, week }

class SchedulePage extends StatefulWidget {
  const SchedulePage({
    super.key,
    required this.scheduleRepository,
    required this.sessionController,
  });

  final ScheduleRepository scheduleRepository;
  final AppSessionController sessionController;

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final ScheduleViewModel _viewModel;
  _ScheduleViewMode _viewMode = _ScheduleViewMode.today;

  @override
  void initState() {
    super.initState();
    _viewModel = ScheduleViewModel(
      scheduleRepository: widget.scheduleRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedule();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    final result = await _viewModel.loadSchedule();
    if (!mounted || result != ScheduleLoadResult.sessionExpired) {
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

  void _setViewMode(_ScheduleViewMode viewMode) {
    setState(() {
      _viewMode = viewMode;
    });
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
                      StudentTopAppBar(title: 'Lịch học', onBack: _goHome),
                      Expanded(
                        child: _ScheduleBody(
                          schedule: state.schedule,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          viewMode: _viewMode,
                          onViewModeChanged: _setViewMode,
                          onRetry: _loadSchedule,
                        ),
                      ),
                      StudentBottomNavigation(
                        currentIndex: 1,
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

class _ScheduleBody extends StatelessWidget {
  const _ScheduleBody({
    required this.schedule,
    required this.isLoading,
    required this.errorMessage,
    required this.viewMode,
    required this.onViewModeChanged,
    required this.onRetry,
  });

  final StudentSchedule? schedule;
  final bool isLoading;
  final String? errorMessage;
  final _ScheduleViewMode viewMode;
  final ValueChanged<_ScheduleViewMode> onViewModeChanged;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedSchedule = schedule;

    if (isLoading && loadedSchedule == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedSchedule == null) {
      return _ScheduleError(message: errorMessage, onRetry: onRetry);
    }

    final weekEnd = loadedSchedule.weekStart.add(const Duration(days: 6));

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(
          'Tuần này',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: FptColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${_formatDate(loadedSchedule.weekStart)} - ${_formatDate(weekEnd)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: FptColors.textSecondary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 18),
        _ScheduleSegmentedControl(
          viewMode: viewMode,
          onChanged: onViewModeChanged,
        ),
        const SizedBox(height: 24),
        if (viewMode == _ScheduleViewMode.today)
          _ScheduleDaySection(
            day: loadedSchedule.todaySchedule,
            emptyMessage: 'Hôm nay chưa có lịch học',
          )
        else
          for (final day in loadedSchedule.days) ...[
            _ScheduleDaySection(day: day, emptyMessage: 'Không có lịch học'),
            const SizedBox(height: 18),
          ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _ScheduleSegmentedControl extends StatelessWidget {
  const _ScheduleSegmentedControl({
    required this.viewMode,
    required this.onChanged,
  });

  final _ScheduleViewMode viewMode;
  final ValueChanged<_ScheduleViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ScheduleSegmentButton(
              label: 'Hôm nay',
              selected: viewMode == _ScheduleViewMode.today,
              onTap: () => onChanged(_ScheduleViewMode.today),
            ),
          ),
          Expanded(
            child: _ScheduleSegmentButton(
              label: 'Tuần này',
              selected: viewMode == _ScheduleViewMode.week,
              onTap: () => onChanged(_ScheduleViewMode.week),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleSegmentButton extends StatelessWidget {
  const _ScheduleSegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? FptColors.orange : FptColors.textSecondary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ScheduleDaySection extends StatelessWidget {
  const _ScheduleDaySection({required this.day, required this.emptyMessage});

  final ScheduleDay? day;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final loadedDay = day;

    if (loadedDay == null) {
      return _EmptySchedule(message: emptyMessage);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${loadedDay.dayLabel}, ${_formatDate(loadedDay.date)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: FptColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
            if (loadedDay.isToday) const _TodayChip(),
          ],
        ),
        const SizedBox(height: 12),
        if (loadedDay.items.isEmpty)
          _EmptySchedule(message: emptyMessage)
        else
          for (final item in loadedDay.items) ...[
            _ScheduleItemTile(item: item),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

class _TodayChip extends StatelessWidget {
  const _TodayChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEDD5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Hôm nay',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: FptColors.orangeDeep,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ScheduleItemTile extends StatelessWidget {
  const _ScheduleItemTile({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final teacherName = item.teacherName;

    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FptColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: FptColors.blue,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                if (teacherName != null && teacherName.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    teacherName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: FptColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 76,
            child: Text(
              item.timeRange,
              maxLines: 2,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
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

  String get _subtitle {
    if (item.roomName.isEmpty) {
      return item.lessonLabel;
    }
    return '${item.lessonLabel} - ${item.roomName}';
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: FptColors.textSecondary,
          height: 1.2,
        ),
      ),
    );
  }
}

class _ScheduleError extends StatelessWidget {
  const _ScheduleError({required this.message, required this.onRetry});

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
              message ?? 'Không thể tải lịch học',
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
