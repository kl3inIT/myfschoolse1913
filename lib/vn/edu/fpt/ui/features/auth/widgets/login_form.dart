import 'package:flutter/material.dart';
import 'package:myfschoolse1913/vn/edu/fpt/ui/features/auth/view_models/login_view_model.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.viewModel,
    required this.onForgotPassword,
    required this.onLogin,
  });

  final LoginViewModel viewModel;
  final VoidCallback onForgotPassword;
  final VoidCallback onLogin;

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
            textInputAction: TextInputAction.next,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: viewModel.validatePhone,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: viewModel.passwordController,
            enabled: !viewModel.isSubmitting,
            obscureText: viewModel.obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onLogin(),
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
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
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: viewModel.isSubmitting ? null : onForgotPassword,
              child: const Text('Quên mật khẩu?'),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: viewModel.isSubmitting ? null : onLogin,
            child: viewModel.isSubmitting
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : const Text('Đăng nhập'),
          ),
          if (viewModel.state.errorMessage case final message?) ...[
            const SizedBox(height: 12),
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
