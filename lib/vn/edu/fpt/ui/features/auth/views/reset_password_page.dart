import 'package:myfschoolse1913/vn/edu/fpt/ui/core/layout/page_frame.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/app_footer.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/reset_password_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/widgets/auth_header.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({
    super.key,
    required this.authRepository,
    required this.resetToken,
  });

  final AuthRepository authRepository;
  final String resetToken;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late final ResetPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ResetPasswordViewModel(
      authRepository: widget.authRepository,
      resetToken: widget.resetToken,
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final result = await _viewModel.submit();
    if (!mounted || result != ResetPasswordSubmitResult.success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công')));
    context.go(AppRoutes.login);
  }

  void _backToLogin() {
    context.go(AppRoutes.login);
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
                        child: ListenableBuilder(
                          listenable: _viewModel,
                          builder: (context, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 32),
                                    child: Transform.translate(
                                      offset: const Offset(-12, 0),
                                      child: IconButton(
                                        tooltip: 'Quay lại',
                                        onPressed: _viewModel.isSubmitting
                                            ? null
                                            : _backToLogin,
                                        icon: const Icon(Icons.arrow_back),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 46),
                                const AuthHeader(),
                                const SizedBox(height: 78),
                                Text(
                                  'Đặt mật khẩu mới',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: FptColors.textPrimary,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                ),
                                const SizedBox(height: 52),
                                _ResetPasswordForm(
                                  viewModel: _viewModel,
                                  onSubmit: _submit,
                                ),
                                const SizedBox(height: 24),
                                TextButton(
                                  onPressed: _viewModel.isSubmitting
                                      ? null
                                      : _backToLogin,
                                  child: const Text('Quay lại đăng nhập'),
                                ),
                                const Spacer(),
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 12),
                                  child: AppFooter(),
                                ),
                              ],
                            );
                          },
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

class _ResetPasswordForm extends StatelessWidget {
  const _ResetPasswordForm({required this.viewModel, required this.onSubmit});

  final ResetPasswordViewModel viewModel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: viewModel.passwordController,
            enabled: !viewModel.isSubmitting,
            obscureText: viewModel.obscurePassword,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Mật khẩu mới',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: viewModel.obscurePassword
                    ? 'Hiện mật khẩu'
                    : 'Ẩn mật khẩu',
                icon: Icon(
                  viewModel.obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: viewModel.isSubmitting
                    ? null
                    : viewModel.toggleObscurePassword,
              ),
            ),
            validator: viewModel.validatePassword,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: viewModel.confirmPasswordController,
            enabled: !viewModel.isSubmitting,
            obscureText: viewModel.obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: 'Nhập lại mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: viewModel.obscureConfirmPassword
                    ? 'Hiện mật khẩu'
                    : 'Ẩn mật khẩu',
                icon: Icon(
                  viewModel.obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: viewModel.isSubmitting
                    ? null
                    : viewModel.toggleObscureConfirmPassword,
              ),
            ),
            validator: viewModel.validateConfirmPassword,
          ),
          const SizedBox(height: 36),
          FilledButton(
            onPressed: viewModel.isSubmitting ? null : onSubmit,
            child: viewModel.isSubmitting
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Đổi mật khẩu'),
          ),
          if (viewModel.state.errorMessage case final message?) ...[
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
