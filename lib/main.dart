import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/theme/app_theme.dart';
import 'package:voice_first_admin/features/home/presentation/pages/home_page.dart';
import 'package:voice_first_admin/core/providers/theme_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 🚨 DEV ONLY — REMOVE AFTER SSL IS FIXED
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Allow ONLY your API domain
        return host == "voicefirst.admin.notetech.com";
      };
  }
}

void main() {
  // ✅ Activate the SSL bypass
  if (kDebugMode) {
    HttpOverrides.global = MyHttpOverrides();
  }
  runApp(const ProviderScope(child: VoiceFirstAdminApp()));
}

class VoiceFirstAdminApp extends ConsumerWidget {
  const VoiceFirstAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch dynamic theme mode
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}
