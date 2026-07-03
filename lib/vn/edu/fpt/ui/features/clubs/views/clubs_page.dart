import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/clubs_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/clubs/view_models/clubs_view_model.dart';

class ClubsPage extends StatefulWidget {
  const ClubsPage({
    super.key,
    required this.clubsRepository,
    required this.sessionController,
  });

  final ClubsRepository clubsRepository;
  final AppSessionController sessionController;

  @override
  State<ClubsPage> createState() => _ClubsPageState();
}

class _ClubsPageState extends State<ClubsPage> {
  late final ClubsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ClubsViewModel(clubsRepository: widget.clubsRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClubs();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadClubs() async {
    final result = await _viewModel.loadClubs();
    if (!mounted || result != ClubsLoadResult.sessionExpired) {
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

  void _openRegistration(StudentClub club) {
    context.go(AppRoutes.clubRegistration, extra: club);
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
                      StudentTopAppBar(title: 'CLB', onBack: _goHome),
                      Expanded(
                        child: _ClubsBody(
                          clubs: state.clubs,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadClubs,
                          onOpenRegistration: _openRegistration,
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

class _ClubsBody extends StatelessWidget {
  const _ClubsBody({
    required this.clubs,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onOpenRegistration,
  });

  final StudentClubs? clubs;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final ValueChanged<StudentClub> onOpenRegistration;

  @override
  Widget build(BuildContext context) {
    final loadedClubs = clubs;

    if (isLoading && loadedClubs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedClubs == null) {
      return _ClubsError(message: errorMessage, onRetry: onRetry);
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          Text(
            'Câu lạc bộ của trường',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: FptColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Theo dõi lịch sinh hoạt và đăng ký tham gia',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FptColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 24),
          if (loadedClubs.clubs.isEmpty)
            const _ClubsEmpty()
          else
            for (final club in loadedClubs.clubs) ...[
              _ClubTile(
                club: club,
                onTap: () => onOpenRegistration(club),
                onRegister: club.canRegister
                    ? () => onOpenRegistration(club)
                    : null,
              ),
              const SizedBox(height: 12),
            ],
          const SizedBox(height: 18),
          const _ClubsNotice(),
        ],
      ),
    );
  }
}

class _ClubTile extends StatelessWidget {
  const _ClubTile({
    required this.club,
    required this.onTap,
    required this.onRegister,
  });

  final StudentClub club;
  final VoidCallback onTap;
  final VoidCallback? onRegister;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FptColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FptColors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.groups_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    club.name,
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
                    club.scheduleText,
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
            if (onRegister == null)
              _ClubStatusChip(status: club.registrationStatus)
            else
              SizedBox(
                height: 30,
                child: FilledButton(
                  onPressed: onRegister,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    textStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  child: Text(club.registrationStatus.label),
                ),
              ),
          ],
        ),
      ),
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
      constraints: const BoxConstraints(minWidth: 74),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _statusBackground(status),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: _statusForeground(status),
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class _ClubsNotice extends StatelessWidget {
  const _ClubsNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FptColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông báo',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: FptColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Học sinh có thể đăng ký CLB mới từ ngày 01 đến 05 hằng tháng.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FptColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubsEmpty extends StatelessWidget {
  const _ClubsEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FptColors.field,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Chưa có câu lạc bộ nào',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: FptColors.textSecondary),
      ),
    );
  }
}

class _ClubsError extends StatelessWidget {
  const _ClubsError({required this.message, required this.onRetry});

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
              message ?? 'Không thể tải danh sách CLB',
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
