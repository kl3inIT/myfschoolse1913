import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_dependencies.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_session_controller.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/forgot_password_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/login_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/reset_password_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/verify_otp_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/grades/views/semester_grades_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/home/views/home_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/schedule/views/schedule_page.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const verifyOtp = '/forgot-password/verify';
  static const resetPassword = '/forgot-password/reset';
  static const home = '/home';
  static const semesterGrades = '/semester-grades';
  static const schedule = '/schedule';
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
      final isProtectedRoute =
          path == AppRoutes.home ||
          path == AppRoutes.semesterGrades ||
          path == AppRoutes.schedule;

      return switch (sessionController.status) {
        AppSessionStatus.checking when isProtectedRoute => AppRoutes.login,
        AppSessionStatus.checking => null,
        AppSessionStatus.unauthenticated when isProtectedRoute =>
          AppRoutes.login,
        AppSessionStatus.authenticated when isLoginRoute => AppRoutes.home,
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
    ],
    errorBuilder: (context, state) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy màn hình')),
      );
    },
  );
}
