import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/theme/app_theme.dart';
import 'package:voice_first_admin/features/home/presentation/pages/home_page.dart';
import 'package:voice_first_admin/core/providers/theme_provider.dart';

void main() {
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
