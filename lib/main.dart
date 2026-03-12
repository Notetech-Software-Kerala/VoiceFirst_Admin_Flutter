import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/theme/app_theme.dart';
import 'package:voice_first_admin/core/providers/theme_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:voice_first_admin/features/auth/presentation/pages/login_screen.dart';
import 'package:voice_first_admin/features/reset_password/presentation/pages/new_password_page.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

/// 🚨 DEV ONLY — REMOVE AFTER SSL IS FIXED
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow ONLY your API domain
        return host == "voicefirst.adminapi.notetech.com";
      };
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void handleResetLink(Uri uri) {
  try {
    if (uri.pathSegments.isEmpty) return;

    // check route
    if (uri.pathSegments.first != "reset-password") return;

    // check token exists
    if (uri.pathSegments.length < 2) {
      debugPrint("Reset link missing token");
      return;
    }

    // final grant = uri.pathSegments[1];
    final grant = uri.pathSegments.length > 1 ? uri.pathSegments[1] : null;

    if (grant == null || grant.isEmpty) {
      debugPrint("Reset token invalid");
      return;
    }

    if (grant.isEmpty) {
      debugPrint("Reset token empty");
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
  // ✅ Activate the SSL bypass
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  runApp(const ProviderScope(child: VoiceFirstAdminApp()));
}

// class VoiceFirstAdminApp extends ConsumerWidget {
//   const VoiceFirstAdminApp({super.key});
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
    // app opened from link
    final uri = await _appLinks.getInitialAppLink();

    if (uri != null) {
      handleResetLink(uri);
    }

    // app already running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      handleResetLink(uri);
    });
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // @override
    // Widget build(BuildContext context, WidgetRef ref) {
    // Watch dynamic theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      home: const LoginScreen(),
    );
  }
}
