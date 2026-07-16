import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_dependencies.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/views/applications_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/applications/views/create_application_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/account/views/account_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/account/views/profile_detail_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/assistant/views/assistant_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/forgot_password_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/login_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/reset_password_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/verify_otp_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/student_clubs.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/clubs/views/club_registration_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/clubs/views/clubs_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/events/views/events_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/grades/views/semester_grades_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/home/views/home_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/views/notification_detail_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/notifications/views/notifications_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/schedule/views/schedule_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/domain/models/user_role.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/parent/views/parent_workspace_page.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const verifyOtp = '/forgot-password/verify';
  static const resetPassword = '/forgot-password/reset';
  static const home = '/home';
  static const parent = '/parent';
  static const mobileUnsupported = '/mobile-unsupported';
  static const assistant = '/assistant';
  static const semesterGrades = '/semester-grades';
  static const schedule = '/schedule';
  static const events = '/events';
  static const applications = '/applications';
  static const createApplication = '/applications/create';
  static const clubs = '/clubs';
  static const clubRegistration = '/clubs/register';
  static const notifications = '/notifications';
  static const notificationDetail = '/notifications/:notificationId';
  static const account = '/account';
  static const accountProfile = '/account/profile';

  static String notificationDetailPath(String notificationId) {
    return '/notifications/$notificationId';
  }
}

class PasswordResetOtpRouteData {
  const PasswordResetOtpRouteData({required this.phoneNumber, this.debugOtp});

  final String phoneNumber;
  final String? debugOtp;
}

class PasswordResetConfirmRouteData {
  const PasswordResetConfirmRouteData({required this.resetToken});

  final String resetToken;
}

GoRouter createAppRouter({required AppSessionController sessionController}) {
  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: sessionController,
    redirect: (context, state) {
      final path = state.uri.path;
      final isLoginRoute = path == AppRoutes.login;
      final isParentRoute = path == AppRoutes.parent;
      final isUnsupportedRoute = path == AppRoutes.mobileUnsupported;
      final isStudentRoute =
          path == AppRoutes.home ||
          path == AppRoutes.assistant ||
          path == AppRoutes.semesterGrades ||
          path == AppRoutes.schedule ||
          path == AppRoutes.events ||
          path == AppRoutes.applications ||
          path == AppRoutes.createApplication ||
          path == AppRoutes.clubs ||
          path == AppRoutes.clubRegistration ||
          path == AppRoutes.notifications ||
          path.startsWith('${AppRoutes.notifications}/') ||
          path == AppRoutes.account ||
          path == AppRoutes.accountProfile;
      final isProtectedRoute =
          isStudentRoute || isParentRoute || isUnsupportedRoute;
      final role = sessionController.session?.user.role;
      final authenticatedLanding = switch (role) {
        UserRole.parent => AppRoutes.parent,
        UserRole.student => AppRoutes.home,
        UserRole.teacher || UserRole.admin => AppRoutes.mobileUnsupported,
        null => AppRoutes.login,
      };

      return switch (sessionController.status) {
        AppSessionStatus.checking when isProtectedRoute => AppRoutes.login,
        AppSessionStatus.checking => null,
        AppSessionStatus.unauthenticated when isProtectedRoute =>
          AppRoutes.login,
        AppSessionStatus.authenticated when isLoginRoute =>
          authenticatedLanding,
        AppSessionStatus.authenticated
            when role == UserRole.parent && isStudentRoute =>
          AppRoutes.parent,
        AppSessionStatus.authenticated
            when role == UserRole.student &&
                (isParentRoute || isUnsupportedRoute) =>
          AppRoutes.home,
        AppSessionStatus.authenticated
            when (role == UserRole.teacher || role == UserRole.admin) &&
                !isUnsupportedRoute =>
          AppRoutes.mobileUnsupported,
        _ => null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: LoginPage(authRepository: services.authRepository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: ForgotPasswordPage(authRepository: services.authRepository),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.verifyOtp,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          final data = state.extra;
          if (data is! PasswordResetOtpRouteData) {
            return NoTransitionPage(
              child: ForgotPasswordPage(
                authRepository: services.authRepository,
              ),
            );
          }

          return NoTransitionPage(
            child: VerifyOtpPage(
              authRepository: services.authRepository,
              phoneNumber: data.phoneNumber,
              debugOtp: data.debugOtp,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          final data = state.extra;
          if (data is! PasswordResetConfirmRouteData) {
            return NoTransitionPage(
              child: ForgotPasswordPage(
                authRepository: services.authRepository,
              ),
            );
          }

          return NoTransitionPage(
            child: ResetPasswordPage(
              authRepository: services.authRepository,
              resetToken: data.resetToken,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: HomePage(
              dashboardRepository: services.dashboardRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.parent,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: ParentWorkspacePage(
              parentRepository: services.parentRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.mobileUnsupported,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: _MobileUnsupportedPage(
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.assistant,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: AssistantPage(
              assistantApiService: services.assistantApiService,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.semesterGrades,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: SemesterGradesPage(
              gradesRepository: services.gradesRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.schedule,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: SchedulePage(
              scheduleRepository: services.scheduleRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.events,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: EventsPage(
              eventsRepository: services.eventsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.applications,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: ApplicationsPage(
              applicationsRepository: services.applicationsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createApplication,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: CreateApplicationPage(
              applicationsRepository: services.applicationsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.clubs,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: ClubsPage(
              clubsRepository: services.clubsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.clubRegistration,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          final club = state.extra;
          if (club is! StudentClub) {
            return NoTransitionPage(
              child: ClubsPage(
                clubsRepository: services.clubsRepository,
                sessionController: services.sessionController,
              ),
            );
          }

          return NoTransitionPage(
            child: ClubRegistrationPage(
              club: club,
              clubsRepository: services.clubsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.account,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: AccountPage(
              userRepository: services.userRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.accountProfile,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: ProfileDetailPage(
              dashboardRepository: services.dashboardRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: NotificationsPage(
              notificationsRepository: services.notificationsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.notificationDetail,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          final notificationId = state.pathParameters['notificationId'];

          if (notificationId == null || notificationId.isEmpty) {
            return NoTransitionPage(
              child: NotificationsPage(
                notificationsRepository: services.notificationsRepository,
                sessionController: services.sessionController,
              ),
            );
          }

          return NoTransitionPage(
            child: NotificationDetailPage(
              notificationId: notificationId,
              notificationsRepository: services.notificationsRepository,
              sessionController: services.sessionController,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy màn hình')),
      );
    },
  );
}

class _MobileUnsupportedPage extends StatelessWidget {
  const _MobileUnsupportedPage({required this.sessionController});

  final AppSessionController sessionController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.desktop_windows_outlined, size: 56),
                const SizedBox(height: 20),
                Text(
                  'Vai trò này sử dụng cổng React',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Giáo viên và quản trị viên đăng nhập trên web. Flutter chỉ dành cho học sinh và phụ huynh.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: sessionController.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
