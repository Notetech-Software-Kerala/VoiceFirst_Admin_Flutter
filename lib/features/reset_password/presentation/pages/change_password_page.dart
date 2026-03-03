import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/reset_password/presentation/pages/forgot_password_page.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_notifier.dart';
import 'package:voice_first_admin/features/reset_password/presentation/providers/password_provider.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final Color brandColor = const Color(0xFF0D7FF2);

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

    ref.listen(passwordProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        if (next.success) {
          _oldPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);

          passwordNotifier.clearSuccess();
        } else if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
          _showError(next.errorMessage!);
          passwordNotifier.clearError();
        }
      }
    });

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _BackgroundLayer(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).maybePop(),
                          padding: const EdgeInsets.only(right: 8),
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Change Password',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          width: double.infinity,
                          constraints: const BoxConstraints(maxWidth: 384),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(8),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withAlpha(20),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Update your account password securely.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF9CA3AF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildInputLabel('CURRENT PASSWORD'),
                                const SizedBox(height: 6),
                                _buildPasswordField(
                                  controller: _oldPasswordController,
                                  hint: 'Enter current password',
                                  validator: (value) {
                                    if ((value ?? '').isEmpty) {
                                      return 'Old password is required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      "Forgot password?",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color.fromARGB(
                                          255,
                                          39,
                                          104,
                                          218,
                                        ),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInputLabel('NEW PASSWORD'),
                                const SizedBox(height: 6),
                                _buildPasswordField(
                                  controller: _newPasswordController,
                                  hint: 'Enter new password',
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
                                const SizedBox(height: 16),
                                _buildInputLabel('CONFIRM PASSWORD'),
                                const SizedBox(height: 6),
                                _buildPasswordField(
                                  controller: _confirmPasswordController,
                                  hint: 'Re-enter new password',
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.isEmpty) {
                                      return 'Confirm password is required';
                                    }
                                    if (text != _newPasswordController.text) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                _buildUpdateButton(
                                  passwordState.isLoading,
                                  passwordNotifier,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4B5563)),
        filled: true,
        fillColor: Colors.white.withAlpha(13),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withAlpha(20)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: brandColor),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildUpdateButton(bool isLoading, PasswordNotifier passwordNotifier) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: brandColor.withAlpha(102),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () async {
                final isValid = _formKey.currentState?.validate();
                if (isValid != true) return;
                await passwordNotifier.changePassword(
                  oldPassword: _oldPasswordController.text,
                  newPassword: _newPasswordController.text,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: brandColor,
          disabledBackgroundColor: brandColor.withAlpha(128),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text('UPDATE PASSWORD'),
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: const Color(0xFF050505)),
        Positioned(
          top: -200,
          left: -200,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0D7FF2).withAlpha(38),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -300,
          right: -200,
          child: Container(
            width: 800,
            height: 800,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF0D7FF2).withAlpha(26),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        Opacity(opacity: 0.1, child: CustomPaint(painter: _WavePainter())),
      ],
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF0D7FF2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paint2 = Paint()
      ..color = const Color(0xFF0D7FF2).withAlpha(128)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path1 = Path();
    final path2 = Path();

    final width = size.width;
    final height = size.height;
    final mid = height / 2;

    path1.moveTo(0, mid);
    for (double i = 0; i <= width; i += 20) {
      path1.lineTo(i, mid + (math.sin(i / 50) * 50));
    }

    path2.moveTo(0, mid + 20);
    for (double i = 0; i <= width; i += 20) {
      path2.lineTo(i, mid + 20 + (math.sin((i + 50) / 60) * 60));
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
