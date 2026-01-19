import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/theme/app_theme.dart';
import 'package:voice_first_admin/features/Program_Action/presentation/pages/view_program_action.dart';
import 'package:voice_first_admin/features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const ProviderScope(child: VoiceFirstAdminApp()));
}

class VoiceFirstAdminApp extends StatelessWidget {
  const VoiceFirstAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const ProgramActionView(),
    );
  }
}
