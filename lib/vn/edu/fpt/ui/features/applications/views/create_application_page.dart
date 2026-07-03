import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/applications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_applications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/view_models/create_application_view_model.dart';

class CreateApplicationPage extends StatefulWidget {
  const CreateApplicationPage({
    super.key,
    required this.applicationsRepository,
    required this.sessionController,
  });

  final ApplicationsRepository applicationsRepository;
  final AppSessionController sessionController;

  @override
  State<CreateApplicationPage> createState() => _CreateApplicationPageState();
}

class _CreateApplicationPageState extends State<CreateApplicationPage> {
  late final CreateApplicationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CreateApplicationViewModel(
      applicationsRepository: widget.applicationsRepository,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      initialDate: _viewModel.state.targetDate ?? now,
      helpText: 'Chọn ngày áp dụng',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (selected != null) {
      _viewModel.setTargetDate(selected);
    }
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Chọn giờ áp dụng',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (selected != null) {
      _viewModel.setRequestedTime(selected);
    }
  }

  Future<void> _submit() async {
    final result = await _viewModel.submit();
    if (!mounted) {
      return;
    }

    if (result == CreateApplicationResult.sessionExpired) {
      await widget.sessionController.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
      return;
    }

    if (result == CreateApplicationResult.success) {
      context.go(AppRoutes.applications);
    }
  }

  void _goBack() {
    context.go(AppRoutes.applications);
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
                      StudentTopAppBar(title: 'Tạo đơn mới', onBack: _goBack),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          children: [
                            DropdownButtonFormField<StudentApplicationType>(
                              initialValue: state.type,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.description_outlined),
                                labelText: 'Loại đơn',
                              ),
                              items: [
                                for (final type
                                    in StudentApplicationType.values)
                                  DropdownMenuItem(
                                    value: type,
                                    child: Text(type.label),
                                  ),
                              ],
                              onChanged: state.isSubmitting
                                  ? null
                                  : (type) {
                                      if (type != null) {
                                        _viewModel.setType(type);
                                      }
                                    },
                            ),
                            const SizedBox(height: 16),
                            _PickerField(
                              icon: Icons.calendar_today_outlined,
                              label: 'Ngày áp dụng',
                              value: state.targetDate == null
                                  ? 'Chọn ngày'
                                  : _formatDate(state.targetDate!),
                              onTap: state.isSubmitting ? null : _pickDate,
                            ),
                            if (state.type.requiresTime) ...[
                              const SizedBox(height: 16),
                              _PickerField(
                                icon: Icons.schedule_outlined,
                                label: 'Giờ áp dụng',
                                value: state.requestedTime ?? 'Chọn giờ',
                                onTap: state.isSubmitting ? null : _pickTime,
                              ),
                            ],
                            const SizedBox(height: 16),
                            TextField(
                              controller: _viewModel.reasonController,
                              enabled: !state.isSubmitting,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.edit_note_outlined),
                                labelText: 'Lý do',
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _viewModel.detailsController,
                              enabled: !state.isSubmitting,
                              minLines: 5,
                              maxLines: 5,
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                                labelText: 'Nội dung chi tiết',
                              ),
                            ),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                state.errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed: state.isSubmitting ? null : _submit,
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Gửi đơn'),
                            ),
                          ],
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
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: InputDecoration(prefixIcon: Icon(icon), labelText: label),
        child: Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: FptColors.textPrimary,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
