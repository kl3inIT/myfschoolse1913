import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/parent_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/parent_workspace.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/parent/view_models/parent_workspace_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/parent/view_models/parent_workspace_state.dart';

class ParentWorkspacePage extends StatefulWidget {
  const ParentWorkspacePage({
    super.key,
    required this.parentRepository,
    required this.sessionController,
  });

  final ParentRepository parentRepository;
  final AppSessionController sessionController;

  @override
  State<ParentWorkspacePage> createState() => _ParentWorkspacePageState();
}

class _ParentWorkspacePageState extends State<ParentWorkspacePage> {
  late final ParentWorkspaceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ParentWorkspaceViewModel(
      parentRepository: widget.parentRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _viewModel.load());
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackdropColor(context),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: pageContentMaxWidth(context)),
            child: ColoredBox(
              color: Colors.white,
              child: ListenableBuilder(
                listenable: _viewModel,
                builder: (context, _) {
                  final state = _viewModel.state;
                  return Column(
                    children: [
                      _ParentHeader(onLogout: widget.sessionController.logout),
                      Expanded(
                        child: _ParentBody(
                          state: state,
                          onRetry: _viewModel.load,
                          onSelectChild: (studentId) =>
                              _viewModel.load(studentId: studentId),
                          onCreateApplication: _openCreateApplication,
                        ),
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

  Future<void> _openCreateApplication() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _CreateApplicationSheet(viewModel: _viewModel),
    );
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi đơn đến nhà trường')),
      );
    }
  }
}

class _ParentHeader extends StatelessWidget {
  const _ParentHeader({required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(24, 40, 12, 12),
      color: FptColors.blue,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.white,
            foregroundColor: FptColors.blue,
            child: Icon(Icons.family_restroom),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Góc phụ huynh',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Theo dõi thông tin đã được nhà trường xác nhận',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: onLogout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ParentBody extends StatelessWidget {
  const _ParentBody({
    required this.state,
    required this.onRetry,
    required this.onSelectChild,
    required this.onCreateApplication,
  });

  final ParentWorkspaceState state;
  final Future<void> Function({String? studentId}) onRetry;
  final ValueChanged<String> onSelectChild;
  final VoidCallback onCreateApplication;

  @override
  Widget build(BuildContext context) {
    final workspace = state.workspace;
    if (state.isLoading && workspace == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (workspace == null) {
      return _ErrorState(message: state.errorMessage, onRetry: onRetry);
    }
    if (workspace.selectedChild == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Tài khoản chưa được nhà trường liên kết với học sinh nào.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final details = workspace.selectedChild!;
    return RefreshIndicator(
      onRefresh: () => onRetry(studentId: details.child.id),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _ChildSelector(workspace: workspace, onSelectChild: onSelectChild),
          const SizedBox(height: 16),
          _OverviewCard(details: details),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Đơn từ',
            actionLabel: 'Tạo đơn',
            onAction: onCreateApplication,
          ),
          const SizedBox(height: 10),
          _ApplicationsCard(items: details.applications),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Điểm đã công bố'),
          const SizedBox(height: 10),
          _GradesCard(items: details.grades),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Chuyên cần gần đây'),
          const SizedBox(height: 10),
          _AttendanceCard(items: details.attendance),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Thời khóa biểu'),
          const SizedBox(height: 10),
          _ScheduleCard(items: details.schedule),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Thông báo nhà trường'),
          const SizedBox(height: 10),
          _NotificationsCard(items: details.notifications),
        ],
      ),
    );
  }
}

class _ChildSelector extends StatelessWidget {
  const _ChildSelector({required this.workspace, required this.onSelectChild});

  final ParentWorkspace workspace;
  final ValueChanged<String> onSelectChild;

  @override
  Widget build(BuildContext context) {
    final selected = workspace.selectedChild!.child;
    return DropdownButtonFormField<String>(
      initialValue: selected.id,
      decoration: const InputDecoration(
        labelText: 'Đang theo dõi học sinh',
        prefixIcon: Icon(Icons.school_outlined),
      ),
      items: workspace.children
          .map(
            (child) => DropdownMenuItem(
              value: child.id,
              child: Text('${child.fullName} · ${child.className}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null && value != selected.id) onSelectChild(value);
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.details});

  final ParentChildDetails details;

  @override
  Widget build(BuildContext context) {
    final child = details.child;
    final absences = details.attendance
        .where((item) => item.status.startsWith('ABSENT'))
        .length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: const Color(0xFFFED7AA)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            child.fullName,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            '${child.studentCode} · ${child.className} · ${details.academicYear}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: FptColors.textSecondary),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _Metric(label: 'Môn có điểm', value: '${details.grades.length}'),
              _Metric(label: 'Lần vắng', value: '$absences'),
              _Metric(
                label: 'Đơn chờ duyệt',
                value:
                    '${details.applications.where((item) => item.status == 'PENDING').length}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FptColors.blue,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: FptColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (actionLabel != null)
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add, size: 18),
            label: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _ApplicationsCard extends StatelessWidget {
  const _ApplicationsCard({required this.items});
  final List<ParentApplicationItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCard('Chưa có đơn nào.');
    return _ListCard(
      children: items.take(4).map((item) {
        return ListTile(
          leading: Icon(_applicationIcon(item.type), color: FptColors.blue),
          title: Text(_applicationLabel(item.type)),
          subtitle: Text('${_date(item.startDate)} · ${item.reason}'),
          trailing: _StatusBadge(status: item.status),
        );
      }).toList(),
    );
  }
}

class _GradesCard extends StatelessWidget {
  const _GradesCard({required this.items});
  final List<ParentSubjectGrade> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCard('Giáo viên chưa công bố đầu điểm nào.');
    }
    return _ListCard(
      children: items.map((item) {
        final scores = item.assessments
            .where((assessment) => assessment.score != null)
            .map((assessment) => assessment.score!.toStringAsFixed(1))
            .join(' · ');
        return ListTile(
          leading: const Icon(Icons.fact_check_outlined, color: FptColors.blue),
          title: Text(item.subjectName),
          subtitle: Text(scores),
          trailing: Text(
            item.average?.toStringAsFixed(1) ?? '—',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: FptColors.blue,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({required this.items});
  final List<ParentAttendanceItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCard('Chưa có dữ liệu chuyên cần.');
    return _ListCard(
      children: items.take(5).map((item) {
        final normal = item.status == 'PRESENT';
        return ListTile(
          leading: Icon(
            normal ? Icons.check_circle_outline : Icons.info_outline,
            color: normal ? const Color(0xFF047857) : FptColors.orangeDeep,
          ),
          title: Text('${item.subjectName} · Tiết ${item.lessonNumber}'),
          subtitle: Text(_date(item.date)),
          trailing: Text(_attendanceLabel(item.status)),
        );
      }).toList(),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.items});
  final List<ParentScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCard('Chưa có thời khóa biểu.');
    return _ListCard(
      children: items.take(6).map((item) {
        return ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFEFF6FF),
            child: Text('${item.lessonNumber}'),
          ),
          title: Text(item.title),
          subtitle: Text(
            'Thứ ${item.dayIndex + 1} · ${_time(item.startsAt)}–${_time(item.endsAt)}'
            '${item.roomName == null ? '' : ' · ${item.roomName}'}',
          ),
        );
      }).toList(),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({required this.items});
  final List<ParentNotificationItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const _EmptyCard('Chưa có thông báo mới.');
    return _ListCard(
      children: items.take(5).map((item) {
        return ListTile(
          leading: Icon(
            item.pinned ? Icons.push_pin_outlined : Icons.notifications_none,
            color: FptColors.blue,
          ),
          title: Text(item.title),
          subtitle: Text(
            item.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: FptColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Divider(height: 1, indent: 16, endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: FptColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: FptColors.textSecondary),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'APPROVED';
    final rejected = status == 'REJECTED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: approved
            ? const Color(0xFFD1FAE5)
            : rejected
            ? const Color(0xFFFEE2E2)
            : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        approved
            ? 'Đã duyệt'
            : rejected
            ? 'Từ chối'
            : 'Chờ duyệt',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _CreateApplicationSheet extends StatefulWidget {
  const _CreateApplicationSheet({required this.viewModel});
  final ParentWorkspaceViewModel viewModel;

  @override
  State<_CreateApplicationSheet> createState() =>
      _CreateApplicationSheetState();
}

class _CreateApplicationSheetState extends State<_CreateApplicationSheet> {
  final _reasonController = TextEditingController();
  String _type = 'ABSENCE';
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _submitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tạo đơn cho học sinh',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Đơn nghỉ tối đa 3 ngày sẽ do giáo viên chủ nhiệm xử lý.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: FptColors.textSecondary),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Loại đơn'),
              items: const [
                DropdownMenuItem(value: 'ABSENCE', child: Text('Xin nghỉ học')),
                DropdownMenuItem(
                  value: 'LATE_ARRIVAL',
                  child: Text('Xin vào muộn'),
                ),
                DropdownMenuItem(
                  value: 'EARLY_LEAVE',
                  child: Text('Xin về sớm'),
                ),
                DropdownMenuItem(
                  value: 'DOCUMENT_REQUEST',
                  child: Text('Xin giấy xác nhận'),
                ),
              ],
              onChanged: (value) => setState(() => _type = value ?? _type),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: 'Từ ngày',
                    value: _startDate,
                    onChanged: (value) {
                      setState(() {
                        _startDate = value;
                        if (_endDate.isBefore(value)) _endDate = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'Đến ngày',
                    value: _endDate,
                    onChanged: (value) => setState(() => _endDate = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              minLines: 2,
              maxLines: 4,
              maxLength: 200,
              decoration: const InputDecoration(
                labelText: 'Lý do',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: const Text('Gửi đơn'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập lý do')));
      return;
    }
    setState(() => _submitting = true);
    final error = await widget.viewModel.createApplication(
      type: _type,
      startDate: _startDate,
      endDate: _endDate,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error == null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final selected = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(_date(value)),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String? message;
  final Future<void> Function({String? studentId}) onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message ?? 'Không thể tải dữ liệu'),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/'
      '${value.month.toString().padLeft(2, '0')}/${value.year}';
}

String _time(String value) => value.length >= 5 ? value.substring(0, 5) : value;

String _applicationLabel(String value) {
  return switch (value) {
    'ABSENCE' => 'Đơn xin nghỉ học',
    'LATE_ARRIVAL' => 'Đơn xin vào muộn',
    'DOCUMENT_REQUEST' => 'Đơn xin giấy xác nhận',
    _ => 'Đơn xin về sớm',
  };
}

IconData _applicationIcon(String value) {
  return value == 'DOCUMENT_REQUEST'
      ? Icons.description_outlined
      : Icons.event_busy_outlined;
}

String _attendanceLabel(String value) {
  return switch (value) {
    'PRESENT' => 'Có mặt',
    'ABSENT_EXCUSED' => 'Vắng có phép',
    'ABSENT_UNEXCUSED' => 'Vắng không phép',
    'LATE' => 'Đi muộn',
    'EARLY_LEAVE' => 'Về sớm',
    _ => value,
  };
}
