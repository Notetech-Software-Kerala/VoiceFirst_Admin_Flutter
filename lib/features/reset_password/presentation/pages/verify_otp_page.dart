import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_provider.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  final String email;

  const VerifyOtpPage({super.key, required this.email});

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
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
          Navigator.of(context).popUntil((route) => route.isFirst);
          passwordNotifier.clearSuccess();
        } else if (next.errorMessage != null) {
          _showError(
            next.errorMessage ?? 'Failed to reset password. Try again.',
          );
          passwordNotifier.clearError();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'OTP'),
                validator: (value) {
                  if ((value ?? '').trim().isEmpty) {
                    return 'OTP is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  final text = value ?? '';
                  if (text.isEmpty) {
                    return 'New password is required';
                  }
                  if (text.length < 8) {
                    return 'Minimum 8 characters';
                  }
                  if (!RegExp(r'[A-Z]').hasMatch(text)) {
                    return 'Include at least one uppercase letter';
                  }
                  if (!RegExp(r'[0-9]').hasMatch(text)) {
                    return 'Include at least one number';
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
                        await passwordNotifier.resetPassword(
                          email: widget.email,
                          otp: _otpController.text.trim(),
                          newPassword: _newPasswordController.text,
                        );
                      },
                child: passwordState.isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
