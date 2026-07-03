import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/notifications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/view_models/notifications_view_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.notificationsRepository,
    required this.sessionController,
  });

  final NotificationsRepository notificationsRepository;
  final AppSessionController sessionController;

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsViewModel(
      notificationsRepository: widget.notificationsRepository,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    final result = await _viewModel.loadNotifications();
    if (!mounted || result != NotificationsLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
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
                      const _NotificationsHeader(),
                      Expanded(
                        child: _NotificationsBody(
                          notifications: state.notifications,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadNotifications,
                        ),
                      ),
                      StudentBottomNavigation(
                        currentIndex: 2,
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

class _NotificationsHeader extends StatelessWidget {
  const _NotificationsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      width: double.infinity,
      color: FptColors.orangeDeep,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
      child: Text(
        'Thông báo',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          height: 1.2,
        ),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.notifications,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final StudentNotifications? notifications;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedNotifications = notifications;

    if (isLoading && loadedNotifications == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedNotifications == null) {
      return _NotificationsError(message: errorMessage, onRetry: onRetry);
    }

    if (loadedNotifications.notifications.isEmpty) {
      return const _NotificationsEmpty();
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          for (final notification in loadedNotifications.notifications) ...[
            _NotificationCard(notification: notification),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final StudentNotification notification;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.pinned ? const Color(0xFFFFF7ED) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.pinned
              ? const Color(0xFFFED7AA)
              : FptColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CategoryChip(category: notification.category),
              if (notification.pinned) ...[
                const SizedBox(width: 8),
                const _PinnedChip(),
              ],
              const Spacer(),
              Text(
                _formatDate(notification.publishedAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: FptColors.textSecondary,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notification.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: FptColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notification.body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: FptColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category});

  final StudentNotificationCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: const Color(0xFF047857),
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class _PinnedChip extends StatelessWidget {
  const _PinnedChip();

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
        'Ghim',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: FptColors.orangeDeep,
          fontWeight: FontWeight.w800,
          height: 1.0,
        ),
      ),
    );
  }
}

class _NotificationsEmpty extends StatelessWidget {
  const _NotificationsEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Chưa có thông báo nào',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: FptColors.textSecondary),
        ),
      ),
    );
  }
}

class _NotificationsError extends StatelessWidget {
  const _NotificationsError({required this.message, required this.onRetry});

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
              message ?? 'Không thể tải thông báo',
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

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}
