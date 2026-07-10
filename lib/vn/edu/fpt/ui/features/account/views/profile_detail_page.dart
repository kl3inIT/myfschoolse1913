import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/dashboard_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_dashboard.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/account/view_models/profile_view_model.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({
    super.key,
    required this.dashboardRepository,
    required this.sessionController,
  });

  final DashboardRepository dashboardRepository;
  final AppSessionController sessionController;

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage> {
  late final ProfileViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ProfileViewModel(
      dashboardRepository: widget.dashboardRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final result = await _viewModel.loadProfile();
    if (!mounted || result != ProfileLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _goBack() {
    context.go(AppRoutes.account);
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
                      StudentTopAppBar(
                        title: 'Thông tin học sinh',
                        onBack: _goBack,
                      ),
                      Expanded(
                        child: _ProfileBody(
                          student: state.student,
                          phoneNumber:
                              widget.sessionController.session?.user
                                  .phoneNumber ??
                              '',
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadProfile,
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

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.student,
    required this.phoneNumber,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final DashboardStudent? student;
  final String phoneNumber;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedStudent = student;

    if (isLoading && loadedStudent == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedStudent == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage ?? 'Không tải được thông tin học sinh.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: FptColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: FptColors.orangeDeep,
            foregroundColor: Colors.white,
            child: Text(
              loadedStudent.initials,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            loadedStudent.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: FptColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 28),
        _ProfileField(label: 'Vai trò', value: loadedStudent.role.label),
        _ProfileField(
          label: 'Lớp',
          value: _stripLabelPrefix(loadedStudent.className, 'Lớp'),
        ),
        _ProfileField(
          label: 'Năm học',
          value: _stripLabelPrefix(loadedStudent.schoolYear, 'Năm học'),
        ),
        _ProfileField(label: 'Trạng thái', value: loadedStudent.status),
        if (phoneNumber.isNotEmpty)
          _ProfileField(label: 'Số điện thoại', value: phoneNumber),
      ],
    );
  }
}

/// The dashboard API returns display strings like 'Lớp 10A1'; drop the
/// part that would repeat the row label.
String _stripLabelPrefix(String value, String label) {
  final prefix = '$label ';
  return value.startsWith(prefix) ? value.substring(prefix.length) : value;
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: FptColors.textSecondary,
                height: 1.2,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: FptColors.textPrimary,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
