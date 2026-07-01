import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/app/app_router.dart';
import 'package:myfschoolse1913/vn/edu/fpt/core/theme/app_colors.dart';
import 'package:myfschoolse1913/vn/edu/fpt/data/repositories/auth_repository.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/core/widgets/app_footer.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/verify_otp_view_model.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/widgets/auth_header.dart';

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({
    super.key,
    required this.authRepository,
    required this.phoneNumber,
    required this.debugOtp,
  });

  final AuthRepository authRepository;
  final String phoneNumber;
  final String? debugOtp;

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  late final VerifyOtpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VerifyOtpViewModel(
      authRepository: widget.authRepository,
      phoneNumber: widget.phoneNumber,
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
    if (!mounted || result != VerifyOtpSubmitResult.success) {
      return;
    }

    context.go(
      AppRoutes.resetPassword,
      extra: PasswordResetConfirmRouteData(
        resetToken: _viewModel.state.resetToken!,
      ),
    );
  }

  void _backToForgotPassword() {
    context.go(AppRoutes.forgotPassword);
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
                                            : _backToForgotPassword,
                                        icon: const Icon(Icons.arrow_back),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 46),
                                const AuthHeader(),
                                const SizedBox(height: 58),
                                Text(
                                  'Nhập mã xác thực',
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
                                const SizedBox(height: 12),
                                Text(
                                  'Mã đã được gửi tới ${widget.phoneNumber}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: FptColors.textSecondary,
                                        height: 1.35,
                                      ),
                                ),
                                if (widget.debugOtp case final code?) ...[
                                  const SizedBox(height: 16),
                                  _DebugOtpBox(code: code),
                                ],
                                const SizedBox(height: 36),
                                _VerifyOtpForm(
                                  viewModel: _viewModel,
                                  onSubmit: _submit,
                                ),
                                const SizedBox(height: 24),
                                TextButton(
                                  onPressed: _viewModel.isSubmitting
                                      ? null
                                      : _backToForgotPassword,
                                  child: const Text('Đổi số điện thoại'),
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

class _VerifyOtpForm extends StatelessWidget {
  const _VerifyOtpForm({required this.viewModel, required this.onSubmit});

  final VerifyOtpViewModel viewModel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: viewModel.otpController,
            enabled: !viewModel.isSubmitting,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            maxLength: 6,
            autofillHints: const [AutofillHints.oneTimeCode],
            onFieldSubmitted: (_) => onSubmit(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 8,
            ),
            decoration: const InputDecoration(
              labelText: 'Mã xác thực',
              counterText: '',
            ),
            validator: viewModel.validateOtp,
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
                : const Text('Xác nhận'),
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

class _DebugOtpBox extends StatelessWidget {
  const _DebugOtpBox({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Text(
        'Mã demo: $code',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: FptColors.orangeDeep,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
