import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_dependencies.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/app_footer.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/login_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/widgets/auth_header.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/widgets/login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginViewModel(authRepository: widget.authRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    final result = await _viewModel.submit();
    if (!mounted) {
      return;
    }

    if (result == LoginSubmitResult.success) {
      final session = _viewModel.state.session;
      if (session != null) {
        AppDependencies.of(context).sessionController.setAuthenticated(session);
      }
      context.go(AppRoutes.home);
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final contentHeight = constraints.maxHeight < 844
                      ? 844.0
                      : constraints.maxHeight;

                  return SingleChildScrollView(
                    child: SizedBox(
                      height: contentHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 142),
                            const AuthHeader(),
                            const SizedBox(height: 173),
                            ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, _) {
                                return LoginForm(
                                  viewModel: _viewModel,
                                  onForgotPassword: () =>
                                      context.go(AppRoutes.forgotPassword),
                                  onLogin: _handleLogin,
                                );
                              },
                            ),
                            const Spacer(),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: AppFooter(),
                            ),
                          ],
                        ),
                      ),
                    ),
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
