import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/app_footer.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/forgot_password_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/widgets/auth_header.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel(authRepository: widget.authRepository);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final result = await _viewModel.submit();
    if (!mounted || result != ForgotPasswordSubmitResult.success) {
      return;
    }

    context.go(
      AppRoutes.verifyOtp,
      extra: PasswordResetOtpRouteData(
        phoneNumber: _viewModel.state.phoneNumber!,
        debugOtp: _viewModel.state.debugOtp,
      ),
    );
  }

  void _backToLogin() {
    context.go(AppRoutes.login);
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
                                  'Quên mật khẩu',
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
                                const SizedBox(height: 60),
                                _ForgotPasswordForm(
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

class _ForgotPasswordForm extends StatelessWidget {
  const _ForgotPasswordForm({required this.viewModel, required this.onSubmit});

  final ForgotPasswordViewModel viewModel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: viewModel.phoneController,
            enabled: !viewModel.isSubmitting,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: viewModel.validatePhone,
          ),
          const SizedBox(height: 36),
          FilledButton(
            onPressed: viewModel.isSubmitting ? null : onSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: FptColors.orangeDeep,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: viewModel.isSubmitting
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Gửi mã xác thực'),
          ),
          if (viewModel.state.successMessage case final message?) ...[
            const SizedBox(height: 16),
            _FeedbackText(message: message, isError: false),
          ],
          if (viewModel.state.errorMessage case final message?) ...[
            const SizedBox(height: 16),
            _FeedbackText(message: message, isError: true),
          ],
        ],
      ),
    );
  }
}

class _FeedbackText extends StatelessWidget {
  const _FeedbackText({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isError
            ? Theme.of(context).colorScheme.error
            : const Color(0xFF047857),
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
    );
  }
}
