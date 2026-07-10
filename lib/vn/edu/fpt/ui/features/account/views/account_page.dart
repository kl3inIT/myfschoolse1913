import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/user_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/app_user.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/account/view_models/account_view_model.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({
    super.key,
    required this.userRepository,
    required this.sessionController,
  });

  final UserRepository userRepository;
  final AppSessionController sessionController;

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late final AccountViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AccountViewModel(
      userRepository: widget.userRepository,
      sessionController: widget.sessionController,
      initialUser: widget.sessionController.session?.user,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAccount();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    final result = await _viewModel.loadAccount();
    if (!mounted || result != AccountLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn sẽ cần đăng nhập lại để sử dụng ứng dụng.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (!mounted || shouldLogout != true) {
      return;
    }

    await _viewModel.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _onDestinationSelected(int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
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
      backgroundColor: pageBackdropColor(context),
      body: SafeArea(
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
                      const _AccountHeader(),
                      Expanded(
                        child: _AccountBody(
                          user: state.user,
                          isLoading: state.isLoading,
                          isLoggingOut: state.isLoggingOut,
                          errorMessage: state.errorMessage,
                          onRetry: _loadAccount,
                          onLogout: _confirmLogout,
                        ),
                      ),
                      StudentBottomNavigation(
                        currentIndex: 3,
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

class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      color: FptColors.orangeDeep,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Text(
        'Tài khoản',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _AccountBody extends StatelessWidget {
  const _AccountBody({
    required this.user,
    required this.isLoading,
    required this.isLoggingOut,
    required this.errorMessage,
    required this.onRetry,
    required this.onLogout,
  });

  final AppUser? user;
  final bool isLoading;
  final bool isLoggingOut;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final loadedUser = user;

    if (isLoading && loadedUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedUser == null) {
      return _AccountError(message: errorMessage, onRetry: onRetry);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      children: [
        _ProfileCard(user: loadedUser),
        if (errorMessage != null) ...[
          const SizedBox(height: 16),
          _AccountWarning(message: errorMessage!, onRetry: onRetry),
        ],
        const SizedBox(height: 28),
        const _AccountListTile(
          icon: Icons.badge_outlined,
          title: 'Thông tin học sinh',
          subtitle: 'Hồ sơ, lớp học, năm học',
        ),
        const SizedBox(height: 10),
        const _AccountListTile(
          icon: Icons.settings_outlined,
          title: 'Cài đặt',
          subtitle: 'Thông báo, bảo mật, ngôn ngữ',
        ),
        const SizedBox(height: 10),
        const _AccountListTile(
          icon: Icons.support_agent_outlined,
          title: 'Hỗ trợ',
          subtitle: 'Liên hệ nhà trường',
        ),
        const SizedBox(height: 10),
        _AccountListTile(
          icon: Icons.logout,
          title: 'Đăng xuất',
          subtitle: 'Thoát khỏi tài khoản',
          onTap: isLoggingOut ? null : onLogout,
          trailing: isLoggingOut
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final AppUser user;

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
              _initials,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: FptColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${user.role.label} · ${user.phoneNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: FptColors.textSecondary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                const _ActiveChip(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _initials {
    final words = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) {
      return 'HS';
    }
    if (words.length == 1) {
      return words.single.characters.first.toUpperCase();
    }
    return '${words.first.characters.first}${words.last.characters.first}'
        .toUpperCase();
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        'Đang hoạt động',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _AccountListTile extends StatelessWidget {
  const _AccountListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 66),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FptColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: enabled ? FptColors.orangeDeep : FptColors.blue),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                    subtitle,
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
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: enabled ? FptColors.orangeDeep : FptColors.blue,
                  size: 22,
                ),
          ],
        ),
      ),
    );
  }
}

class _AccountWarning extends StatelessWidget {
  const _AccountWarning({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: FptColors.textSecondary),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tải lại')),
        ],
      ),
    );
  }
}

class _AccountError extends StatelessWidget {
  const _AccountError({required this.message, required this.onRetry});

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
              message ?? 'Không thể tải tài khoản',
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
