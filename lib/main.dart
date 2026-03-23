import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/theme/app_theme.dart';
import 'package:voice_first_admin/core/providers/theme_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:voice_first_admin/features/auth/presentation/pages/login_screen.dart';
import 'package:voice_first_admin/features/auth/presentation/providers/auth_provider.dart';
import 'package:voice_first_admin/features/home/presentation/pages/home_page.dart';
import 'package:voice_first_admin/features/reset_password/presentation/pages/new_password_page.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

/// 🚨 DEV ONLY — REMOVE AFTER SSL IS FIXED
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host == "voicefirst.adminapi.notetech.com";
      };
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleResetLink(Uri uri) {
  try {
    if (uri.pathSegments.isEmpty) return;

    if (uri.pathSegments.first != "reset-password") return;

    final grant = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;

    if (grant == null || grant.isEmpty) {
      debugPrint("Reset token invalid");
      return;
    }

    Future.delayed(Duration.zero, () {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => NewPasswordPage(grant: grant)),
        (route) => false,
      );
    });
  } catch (e) {
    debugPrint("Deep link error: $e");
  }
}

void main() {
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  runApp(const ProviderScope(child: VoiceFirstAdminApp()));
}

class VoiceFirstAdminApp extends ConsumerStatefulWidget {
  const VoiceFirstAdminApp({super.key});

  @override
  ConsumerState<VoiceFirstAdminApp> createState() => _VoiceFirstAdminAppState();
}

class _VoiceFirstAdminAppState extends ConsumerState<VoiceFirstAdminApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final uri = await _appLinks.getInitialAppLink();
    if (uri != null) handleResetLink(uri);
    _linkSubscription = _appLinks.uriLinkStream.listen(handleResetLink);
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeAnimationDuration: Duration.zero,
      navigatorKey: navigatorKey,
      home: const AuthGate(),
    );
  }
}

/// Routes to [HomePage] if already authenticated, otherwise [LoginScreen].
/// Shows a loading splash while the auth check is in progress.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (auth.isLoading) {
      // Splash while stored token is being checked
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (auth.isAuthenticated) {
      return const HomePage();
    }

    return const LoginScreen();
  }
}
