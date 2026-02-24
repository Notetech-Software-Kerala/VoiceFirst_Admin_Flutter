import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/home/presentation/pages/home_page.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final Color brandColor = const Color(0xFF0D7FF2);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter corporate email and password'),
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await ref
        .read(authProvider.notifier)
        .login(email, password);

    if (success && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } else if (mounted) {
      final error = ref.read(authProvider).error ?? 'Login failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Immersive Background (Gradients + Waves)
          const _BackgroundLayer(),

          // 2. Main Scrollable Content
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
                    // Branding & Animated Logo
                    const _BrandingHeader(),
                    const SizedBox(height: 40),

                    // Glassmorphism Login Card
                    _buildLoginCard(context, authState.isLoading),
                    const SizedBox(height: 48),

                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, bool isLoading) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 384), // max-w-sm
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Email Field
              _buildInputLabel("CORPORATE EMAIL"),
              const SizedBox(height: 6),
              _buildTextField(
                hint: "name@company.com",
                isObscure: false,
                controller: _emailController,
                enabled: !isLoading,
              ),
              const SizedBox(height: 24),

              // Password Field
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInputLabel("SECURITY KEY"),
                  Text(
                    "Forgot?",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: brandColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _buildTextField(
                hint: "••••••••",
                isObscure: true,
                controller: _passwordController,
                enabled: !isLoading,
              ),
              const SizedBox(height: 32),

              // Sign In Button
              _buildSignInButton(context, isLoading),
              const SizedBox(height: 32),

              // Divider
              _buildDivider(),
              const SizedBox(height: 32),

              // Face ID Section
              _buildBiometricLogin(),
            ],
          ),
        ),
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
          color: Color(0xFF9CA3AF), // gray-400
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required bool isObscure,
    required TextEditingController controller,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      enabled: enabled,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4B5563)), // gray-600
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: brandColor),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context, bool isLoading) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          // The Glow Effect
          BoxShadow(
            color: brandColor.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _onLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: brandColor,
          disabledBackgroundColor: brandColor.withValues(alpha: 0.5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          elevation: 0, // Handled by Container shadow
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text("SIGN IN"),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            "OR",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2.0,
              color: Color(0xFF6B7280), // gray-500
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
      ],
    );
  }

  Widget _buildBiometricLogin() {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.05),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.face, // Using standard face icon for biometric
              color: Colors.white70,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "SIGN IN WITH FACE ID",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            children: [
              TextSpan(text: "New to the platform? "),
              TextSpan(
                text: "Request Access",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "SECURE ENCRYPTION • ENTERPRISE GRADE",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.0,
            color: Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// ADVANCED UI COMPONENTS (Animations & Custom Painting)
// -----------------------------------------------------------------------------

class _BrandingHeader extends StatefulWidget {
  const _BrandingHeader();

  @override
  State<_BrandingHeader> createState() => _BrandingHeaderState();
}

class _BrandingHeaderState extends State<_BrandingHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const brandColor = Color(0xFF0D7FF2);

    return Column(
      children: [
        // Animated Logo Bars
        SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _AnimatedBar(
                controller: _controller,
                height: 16,
                offset: 0.0,
                color: brandColor,
              ),
              _AnimatedBar(
                controller: _controller,
                height: 32,
                offset: 0.2,
                color: brandColor,
              ),
              _AnimatedBar(
                controller: _controller,
                height: 40,
                offset: 0.4,
                color: brandColor,
              ),
              _AnimatedBar(
                controller: _controller,
                height: 24,
                offset: 0.1,
                color: brandColor,
              ),
              _AnimatedBar(
                controller: _controller,
                height: 36,
                offset: 0.3,
                color: brandColor,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Gradient Text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Colors.white, Color(0xFF9CA3AF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: const Text(
            "VoiceFirst",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),

        const SizedBox(height: 4),
        const Text(
          "ENTERPRISE SOLUTIONS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 3.0,
            color: brandColor,
          ),
        ),
      ],
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  final AnimationController controller;
  final double height;
  final double offset;
  final Color color;

  const _AnimatedBar({
    required this.controller,
    required this.height,
    required this.offset,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Create a continuous sine wave effect based on time and offset
        final double wave = math.sin(
          (controller.value * 2 * math.pi) + (offset * math.pi * 2),
        );
        // Map wave (-1 to 1) to scale (1.0 to 1.8) and opacity (0.3 to 0.8)
        final double scale = 1.0 + ((wave + 1) / 2) * 0.8;
        final double opacity = 0.3 + ((wave + 1) / 2) * 0.5;

        return Transform.scale(
          scaleY: scale,
          alignment: Alignment.bottomCenter,
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 6,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
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
        // Dark Base
        Container(color: const Color(0xFF050505)),

        // Top Left Radial Gradient
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
                  const Color(0xFF0D7FF2).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // Bottom Right Radial Gradient
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
                  const Color(0xFF0D7FF2).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // Custom Painted SVG Wave Mimic
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
      ..color = const Color(0xFF0D7FF2).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path1 = Path();
    final path2 = Path();

    final width = size.width;
    final height = size.height;
    final mid = height / 2;

    // Approximating the bezier curves from the SVG
    path1.moveTo(0, mid);
    for (double i = 0; i <= width; i += 20) {
      path1.lineTo(i, mid + math.sin(i / 50) * 50);
    }

    path2.moveTo(0, mid + 20);
    for (double i = 0; i <= width; i += 20) {
      path2.lineTo(i, mid + 20 + math.sin((i + 50) / 60) * 60);
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
