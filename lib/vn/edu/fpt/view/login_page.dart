import 'package:flutter/material.dart';

import '../controller/login_controller.dart';
import 'widgets/login_form.dart';
import 'widgets/login_header.dart';

/// View: full-screen login page for the FPT Schools app.
///
/// Creates and owns the [LoginController], rebuilds when it notifies, and
/// composes the reusable header and form. Wrapped in [SafeArea] +
/// [SingleChildScrollView] so the keyboard never overflows; the footer is
/// pinned to the bottom via [Spacer] inside an [IntrinsicHeight].
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
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Center(
                    // Keep the form readable on tablets / large phones.
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: Column(
                        children: [
                          // Logo + form, vertically centred in the space
                          // above the footer.
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const LoginHeader(),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      24,
                                      8,
                                      24,
                                      0,
                                    ),
                                    child: ListenableBuilder(
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 24, bottom: 16),
                            child: _Footer(),
                          ),
                        ],
                      ),
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

/// Bottom footer: app version above the copyright line.
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
        Text('Phiên bản 1.0.0', style: style),
        const SizedBox(height: 2),
        Text('© 2026 FPT Schools', style: style),
      ],
    );
  }
}
