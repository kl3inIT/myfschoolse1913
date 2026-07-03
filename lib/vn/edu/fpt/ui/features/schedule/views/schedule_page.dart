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
  DateTime? _selectedDate;

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

  Future<void> _loadSchedule({DateTime? weekStart}) async {
    final result = await _viewModel.loadSchedule(weekStart: weekStart);
    if (!mounted) {
      return;
    }

    if (result == ScheduleLoadResult.sessionExpired) {
      await widget.sessionController.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
      return;
    }

    if (result == ScheduleLoadResult.success) {
      final schedule = _viewModel.state.schedule;
      if (schedule != null) {
        setState(() {
          _selectedDate = _preferredSelectedDate(schedule);
        });
      }
    }
  }

  DateTime _preferredSelectedDate(StudentSchedule schedule) {
    final selectedDate = _selectedDate;
    if (selectedDate != null &&
        _dayForDate(schedule.days, selectedDate) != null) {
      return selectedDate;
    }

    final today = schedule.todaySchedule;
    if (today != null) {
      return today.date;
    }

    return schedule.days.first.date;
  }

  Future<void> _loadAdjacentWeek(int weekOffset) async {
    final currentSchedule = _viewModel.state.schedule;
    if (currentSchedule == null) {
      return;
    }

    await _loadSchedule(
      weekStart: currentSchedule.weekStart.add(Duration(days: 7 * weekOffset)),
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
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
      case 2:
        context.go(AppRoutes.notifications);
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
                      StudentTopAppBar(title: 'Lịch học', onBack: _goHome),
                      Expanded(
                        child: _ScheduleBody(
                          schedule: state.schedule,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          selectedDate: _selectedDate,
                          onDateSelected: _selectDate,
                          onPreviousWeek: () => _loadAdjacentWeek(-1),
                          onNextWeek: () => _loadAdjacentWeek(1),
                          onRetry: () => _loadSchedule(
                            weekStart: state.schedule?.weekStart,
                          ),
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
    required this.selectedDate,
    required this.onDateSelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onRetry,
  });

  final StudentSchedule? schedule;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
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

    final selectedDay =
        _dayForDate(loadedSchedule.days, selectedDate) ??
        loadedSchedule.todaySchedule ??
        loadedSchedule.days.first;
    final weekEnd = loadedSchedule.weekStart.add(const Duration(days: 6));

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          children: [
            _ScheduleWeekHeader(
              weekStart: loadedSchedule.weekStart,
              weekEnd: weekEnd,
              academicYearName: loadedSchedule.academicYearName,
              semesterName: loadedSchedule.semesterName,
              onPreviousWeek: onPreviousWeek,
              onNextWeek: onNextWeek,
            ),
            const SizedBox(height: 24),
            _WeekDaySelector(
              days: loadedSchedule.days,
              selectedDate: selectedDay.date,
              onDateSelected: onDateSelected,
            ),
            const SizedBox(height: 28),
            _ScheduleDaySection(
              day: selectedDay,
              emptyMessage: 'Ngày này chưa có lịch học',
            ),
          ],
        ),
        if (isLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}

class _ScheduleWeekHeader extends StatelessWidget {
  const _ScheduleWeekHeader({
    required this.weekStart,
    required this.weekEnd,
    required this.academicYearName,
    required this.semesterName,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final String academicYearName;
  final String semesterName;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tuần ${_formatShortDate(weekStart)} - ${_formatShortDate(weekEnd)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: FptColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$academicYearName · $semesterName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FptColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            _WeekArrowButton(
              icon: Icons.chevron_left,
              tooltip: 'Tuần trước',
              onPressed: onPreviousWeek,
            ),
            const SizedBox(width: 8),
            _WeekArrowButton(
              icon: Icons.chevron_right,
              tooltip: 'Tuần sau',
              onPressed: onNextWeek,
            ),
          ],
        ),
      ],
    );
  }
}

class _WeekArrowButton extends StatelessWidget {
  const _WeekArrowButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: FptColors.textPrimary,
          side: const BorderSide(color: FptColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon, size: 22),
      ),
    );
  }
}

class _WeekDaySelector extends StatelessWidget {
  const _WeekDaySelector({
    required this.days,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final List<ScheduleDay> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < days.length; index++) ...[
          if (index > 0) const SizedBox(width: 8),
          _WeekDayChip(
            day: days[index],
            selected: _isSameDate(days[index].date, selectedDate),
            onTap: () => onDateSelected(days[index].date),
          ),
        ],
      ],
    );
  }
}

class _WeekDayChip extends StatelessWidget {
  const _WeekDayChip({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final ScheduleDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : FptColors.textPrimary;
    final secondary = selected ? Colors.white : FptColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 42,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? FptColors.orangeDeep : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? FptColors.orangeDeep : FptColors.border,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _weekdayShort(day.date),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: secondary,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day.date.day.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleDaySection extends StatelessWidget {
  const _ScheduleDaySection({required this.day, required this.emptyMessage});

  final ScheduleDay day;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${day.dayLabel}, ${_formatShortDate(day.date)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: FptColors.textPrimary,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _daySummary(day),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: FptColors.textSecondary,
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        if (day.items.isEmpty)
          _EmptySchedule(message: emptyMessage)
        else
          for (final session in ScheduleSession.values) ...[
            _ScheduleSessionGroup(
              session: session,
              items: _itemsForSession(session),
            ),
          ],
      ],
    );
  }

  String _daySummary(ScheduleDay day) {
    final lessonCount = day.items
        .where((item) => item.type == ScheduleItemType.subject)
        .length;
    final mealCount = day.items
        .where((item) => item.type == ScheduleItemType.meal)
        .length;
    final activityCount = day.items
        .where((item) => item.type == ScheduleItemType.activity)
        .length;
    final parts = <String>[];

    if (lessonCount > 0) {
      parts.add('$lessonCount tiết học');
    }
    if (mealCount > 0) {
      parts.add('ăn trưa/nghỉ trưa');
    }
    if (activityCount > 0) {
      parts.add('$activityCount hoạt động');
    }

    if (parts.isEmpty) {
      return 'Không có lịch học';
    }
    return parts.join(' · ');
  }

  List<ScheduleItem> _itemsForSession(ScheduleSession session) {
    return day.items.where((item) => item.session == session).toList();
  }
}

class _ScheduleSessionGroup extends StatelessWidget {
  const _ScheduleSessionGroup({required this.session, required this.items});

  final ScheduleSession session;
  final List<ScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SessionMarker(session: session),
              const SizedBox(width: 8),
              Text(
                session.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: FptColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items) ...[
            _ScheduleItemTile(item: item),
            if (item != items.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SessionMarker extends StatelessWidget {
  const _SessionMarker({required this.session});

  final ScheduleSession session;

  @override
  Widget build(BuildContext context) {
    final color = switch (session) {
      ScheduleSession.morning => FptColors.blue,
      ScheduleSession.noon => const Color(0xFF047857),
      ScheduleSession.afternoon => FptColors.orangeDeep,
    };

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _ScheduleItemTile extends StatelessWidget {
  const _ScheduleItemTile({required this.item});

  final ScheduleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _startTime,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: FptColors.blue,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                if (item.type == ScheduleItemType.meal) ...[
                  const SizedBox(height: 8),
                  const _MealChip(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    if (item.type == ScheduleItemType.meal) {
      if (item.roomName.isEmpty) {
        return 'Ăn trưa / nghỉ trưa';
      }
      return 'Ăn trưa / nghỉ trưa · ${item.roomName}';
    }
    if (item.roomName.isEmpty) {
      return item.lessonLabel;
    }
    return '${item.lessonLabel} · ${item.roomName}';
  }

  String get _startTime {
    return item.timeRange.split(' - ').first;
  }
}

class _MealChip extends StatelessWidget {
  const _MealChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        'Giữa ngày',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  const _EmptySchedule({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
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

ScheduleDay? _dayForDate(List<ScheduleDay> days, DateTime? date) {
  if (date == null) {
    return null;
  }

  for (final day in days) {
    if (_isSameDate(day.date, date)) {
      return day;
    }
  }

  return null;
}

bool _isSameDate(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatShortDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}

String _weekdayShort(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'T2',
    DateTime.tuesday => 'T3',
    DateTime.wednesday => 'T4',
    DateTime.thursday => 'T5',
    DateTime.friday => 'T6',
    DateTime.saturday => 'T7',
    _ => 'CN',
  };
}
