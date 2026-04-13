import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/core/theme/app_theme.dart';

void configureTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

void main() {
  configureTestEnvironment();
  // setUpAll(() {
  //   // Ensure bindings and disable network font fetching for tests
  //   TestWidgetsFlutterBinding.ensureInitialized();
  //   GoogleFonts.config.allowRuntimeFetching = false;
  // });

  group('AppTheme', () {
    test('lightTheme should have correct brightness', () {
      final theme = AppTheme.lightTheme;
      expect(theme.brightness, Brightness.light);
    });

    test('darkTheme should have correct brightness', () {
      final theme = AppTheme.darkTheme;
      expect(theme.brightness, Brightness.dark);
    });

    test('lightTheme should have correct colors', () {
      final theme = AppTheme.lightTheme;
      expect(theme.scaffoldBackgroundColor, AppTheme.bgLight);
      expect(theme.primaryColor, AppTheme.primaryColor);
      expect(theme.cardColor, AppTheme.cardLight);
    });

    test('darkTheme should have correct colors', () {
      final theme = AppTheme.darkTheme;
      expect(theme.scaffoldBackgroundColor, AppTheme.bgDark);
      expect(theme.primaryColor, AppTheme.primaryColor);
      expect(theme.cardColor, AppTheme.cardDark);
    });

    test('primary color should be consistent across themes', () {
      final lightTheme = AppTheme.lightTheme;
      final darkTheme = AppTheme.darkTheme;
      expect(lightTheme.primaryColor, darkTheme.primaryColor);
      expect(lightTheme.primaryColor, const Color(0xFF0D7FF2));
    });

    test('theme should have text theme configured', () {
      final theme = AppTheme.lightTheme;
      expect(theme.textTheme, isNotNull);
      expect(theme.textTheme.bodyLarge, isNotNull);
      expect(theme.textTheme.bodyMedium, isNotNull);
    });
  });
}
