import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Helper to create a ProviderContainer for testing
ProviderContainer createContainer({
  List<Override>? overrides,
  ProviderContainer? parent,
}) {
  final container = ProviderContainer(
    overrides: overrides ?? [],
    parent: parent,
  );

  addTearDown(container.dispose);
  return container;
}

/// Helper to test async provider states
Future<void> pumpEventQueue() async {
  await Future.delayed(Duration.zero);
}
