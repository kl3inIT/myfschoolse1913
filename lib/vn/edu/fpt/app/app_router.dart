import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_dependencies.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/forgot_password_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/views/login_page.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/home/views/home_page.dart';

abstract final class AppRoutes {
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
}

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.login,
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
        path: AppRoutes.home,
        pageBuilder: (context, state) {
          final services = AppDependencies.of(context);
          return NoTransitionPage(
            child: HomePage(authRepository: services.authRepository),
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
