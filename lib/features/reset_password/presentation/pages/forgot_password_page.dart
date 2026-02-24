import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/reset_password/presentation/pages/verify_otp_page.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final passwordState = ref.watch(passwordProvider);
    final passwordNotifier = ref.read(passwordProvider.notifier);

    ref.listen(passwordProvider, (prev, next) {
      if (prev?.isLoading == true && next.isLoading == false) {
        if (next.success) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  VerifyOtpPage(email: _emailController.text.trim()),
            ),
          );
          passwordNotifier.clearSuccess();
        } else if (next.errorMessage != null) {
          _showError(next.errorMessage ?? 'Failed to send OTP. Try again.');
          passwordNotifier.clearError();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Email is required';
                  }
                  if (!text.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: passwordState.isLoading
                    ? null
                    : () async {
                        final isValid = _formKey.currentState?.validate();
                        if (isValid != true) return;
                        await passwordNotifier.forgotPassword(
                          _emailController.text.trim(),
                        );
                      },
                child: passwordState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
