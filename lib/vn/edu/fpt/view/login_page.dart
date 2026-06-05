import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

/// View: full-screen login page for the FPT Schools app.
///
/// Creates and owns the [LoginController], rebuilds when it notifies, and
/// composes the reusable header and form. Wrapped in [SafeArea] +
/// [SingleChildScrollView] so the keyboard never overflows.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LoginController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleLogin() {
    FocusScope.of(context).unfocus();
    if (_controller.submit() == LoginResult.success) {
      _showSnackBar('Đã bấm đăng nhập');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  // Keep the form readable on tablets / large phones.
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LoginHeader(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Đăng nhập để tiếp tục',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Rebuild on controller changes (e.g. show/hide password).
                              ListenableBuilder(
                                listenable: _controller,
                                builder: (context, _) {
                                  return LoginForm(
                                    controller: _controller,
                                    onForgotPassword: () => _showSnackBar(
                                      'Tính năng quên mật khẩu sắp ra mắt',
                                    ),
                                    onLogin: _handleLogin,
                                  );
                                },
                              ),
                              const SizedBox(height: 32),
                              const _Footer(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Bottom footer: copyright + app version.
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Text('© 2026 FPT Schools', style: style),
        const SizedBox(height: 2),
        Text('Phiên bản 1.0.0', style: style),
      ],
    );
  }
}
