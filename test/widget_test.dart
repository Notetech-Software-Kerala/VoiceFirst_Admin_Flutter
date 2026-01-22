import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voice_first_admin/main.dart';

void main() {
  group('VoiceFirstAdminApp Widget Tests', () {
    test('VoiceFirstAdminApp should be a StatelessWidget', () {
      expect(const VoiceFirstAdminApp(), isA<StatelessWidget>());
    });

    test('App should be instantiable', () {
      const app = VoiceFirstAdminApp();
      expect(app, isNotNull);
      expect(app, isA<Widget>());
    });
  });
}
