import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/clubs_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/clubs/view_models/club_registration_view_model.dart';

class ClubRegistrationPage extends StatefulWidget {
  const ClubRegistrationPage({
    super.key,
    required this.club,
    required this.clubsRepository,
    required this.sessionController,
  });

  final StudentClub club;
  final ClubsRepository clubsRepository;
  final AppSessionController sessionController;

  @override
  State<ClubRegistrationPage> createState() => _ClubRegistrationPageState();
}

class _ClubRegistrationPageState extends State<ClubRegistrationPage> {
  late final ClubRegistrationViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ClubRegistrationViewModel(
      clubsRepository: widget.clubsRepository,
      club: widget.club,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final result = await _viewModel.submit();
    if (!mounted) {
      return;
    }

    if (result == ClubRegistrationResult.sessionExpired) {
      await widget.sessionController.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
      return;
    }

    if (result == ClubRegistrationResult.success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã gửi đăng ký CLB')));
      context.go(AppRoutes.clubs);
    }
  }

  void _goBack() {
    context.go(AppRoutes.clubs);
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
                      StudentTopAppBar(title: 'Đăng ký CLB', onBack: _goBack),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                          children: [
                            _ClubDetailCard(club: state.club),
                            const SizedBox(height: 22),
                            _RegistrationNote(club: state.club),
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 18),
                              Text(
                                state.errorMessage!,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            FilledButton(
                              onPressed:
                                  state.club.canRegister && !state.isSubmitting
                                  ? _submit
                                  : null,
                              child: state.isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(_submitLabel(state.club)),
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

class _ClubDetailCard extends StatelessWidget {
  const _ClubDetailCard({required this.club});

  final StudentClub club;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FptColors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: FptColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ClubStatusChip(status: club.registrationStatus),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            club.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FptColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          _ClubMetaRow(
            icon: Icons.calendar_month_outlined,
            text: club.scheduleText,
          ),
          const SizedBox(height: 10),
          _ClubMetaRow(icon: Icons.place_outlined, text: club.location),
        ],
      ),
    );
  }
}

class _RegistrationNote extends StatelessWidget {
  const _RegistrationNote({required this.club});

  final StudentClub club;

  @override
  Widget build(BuildContext context) {
    final text = club.canRegister
        ? 'Sau khi gửi đăng ký, nhà trường sẽ xét duyệt và thông báo kết quả trên ứng dụng.'
        : 'Trạng thái đăng ký hiện tại của bạn là "${club.registrationStatus.label}".';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: FptColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }
}

class _ClubMetaRow extends StatelessWidget {
  const _ClubMetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: FptColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FptColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClubStatusChip extends StatelessWidget {
  const _ClubStatusChip({required this.status});

  final ClubRegistrationStatus status;

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

String _submitLabel(StudentClub club) {
  return club.canRegister ? 'Gửi đăng ký' : club.registrationStatus.label;
}

Color _statusBackground(ClubRegistrationStatus status) {
  return switch (status) {
    ClubRegistrationStatus.none => const Color(0xFFD1FAE5),
    ClubRegistrationStatus.pending => const Color(0xFFFEF3C7),
    ClubRegistrationStatus.approved => const Color(0xFFD1FAE5),
    ClubRegistrationStatus.rejected => const Color(0xFFFEE2E2),
  };
}

Color _statusForeground(ClubRegistrationStatus status) {
  return switch (status) {
    ClubRegistrationStatus.none => const Color(0xFF047857),
    ClubRegistrationStatus.pending => const Color(0xFF92400E),
    ClubRegistrationStatus.approved => const Color(0xFF047857),
    ClubRegistrationStatus.rejected => const Color(0xFFB91C1C),
  };
}
