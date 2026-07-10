import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/notifications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/view_models/notifications_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/widgets/notification_chips.dart';

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

  Future<void> _openNotification(String notificationId) async {
    await context.push(AppRoutes.notificationDetailPath(notificationId));
    if (mounted) {
      await _loadNotifications();
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
                      const _NotificationsHeader(),
                      Expanded(
                        child: _NotificationsBody(
                          notifications: state.notifications,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadNotifications,
                          onNotificationSelected: _openNotification,
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
    required this.onNotificationSelected,
  });

  final StudentNotifications? notifications;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final Future<void> Function(String notificationId) onNotificationSelected;

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
            _NotificationCard(
              notification: notification,
              onTap: () {
                onNotificationSelected(notification.id);
              },
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final StudentNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cardColor = notification.pinned
        ? const Color(0xFFFFF7ED)
        : Colors.white;
    final borderColor = notification.pinned
        ? const Color(0xFFFED7AA)
        : FptColors.border;

    return Material(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  NotificationCategoryChip(category: notification.category),
                  if (notification.pinned) ...[
                    const SizedBox(width: 8),
                    const PinnedNotificationChip(),
                  ],
                  const Spacer(),
                  Text(
                    formatNotificationDate(notification.publishedAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: FptColors.textSecondary,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!notification.read) ...[
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 5, right: 8),
                      decoration: const BoxDecoration(
                        color: FptColors.orangeDeep,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  Expanded(
                    child: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: FptColors.textPrimary,
                        fontWeight: notification.read
                            ? FontWeight.w700
                            : FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notification.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: FptColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right,
                  color: notification.read
                      ? FptColors.textSecondary
                      : FptColors.orangeDeep,
                  size: 22,
                ),
              ),
            ],
          ),
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
