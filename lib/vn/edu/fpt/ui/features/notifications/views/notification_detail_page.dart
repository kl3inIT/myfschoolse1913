import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_top_app_bar.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/notifications_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_notifications.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/student_bottom_navigation.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/view_models/notification_detail_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/widgets/notification_chips.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage({
    super.key,
    required this.notificationId,
    required this.notificationsRepository,
    required this.sessionController,
  });

  final String notificationId;
  final NotificationsRepository notificationsRepository;
  final AppSessionController sessionController;

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  late final NotificationDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationDetailViewModel(
      notificationsRepository: widget.notificationsRepository,
      notificationId: widget.notificationId,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotification();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _loadNotification() async {
    final result = await _viewModel.loadNotification();
    if (!mounted || result != NotificationDetailLoadResult.sessionExpired) {
      return;
    }

    await widget.sessionController.logout();
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go(AppRoutes.notifications);
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
                        title: 'Chi tiết thông báo',
                        onBack: _goBack,
                      ),
                      Expanded(
                        child: _NotificationDetailBody(
                          notification: state.notification,
                          isLoading: state.isLoading,
                          errorMessage: state.errorMessage,
                          onRetry: _loadNotification,
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


class _NotificationDetailBody extends StatelessWidget {
  const _NotificationDetailBody({
    required this.notification,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  final StudentNotificationDetail? notification;
  final bool isLoading;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final loadedNotification = notification;

    if (isLoading && loadedNotification == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (loadedNotification == null) {
      return _NotificationDetailError(message: errorMessage, onRetry: onRetry);
    }

    return RefreshIndicator(
      onRefresh: onRetry,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NotificationCategoryChip(category: loadedNotification.category),
              if (loadedNotification.pinned) const PinnedNotificationChip(),
              Text(
                formatNotificationDate(loadedNotification.publishedAt),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FptColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            loadedNotification.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: FptColors.textPrimary,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            loadedNotification.body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: FptColors.textPrimary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationDetailError extends StatelessWidget {
  const _NotificationDetailError({
    required this.message,
    required this.onRetry,
  });

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
              message ?? 'Không thể tải chi tiết thông báo',
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
