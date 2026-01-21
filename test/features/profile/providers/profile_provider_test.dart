import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/features/profile/presentation/providers/profile_provider.dart';

void main() {
  group('ProfileState', () {
    test('should create instance with all fields', () {
      final state = ProfileState(
        pushNotifications: true,
        emailAlerts: false,
        userName: 'John Doe',
        userRole: 'Administrator',
        userId: '123',
        profileImageUrl: 'https://example.com/image.jpg',
      );

      expect(state.pushNotifications, true);
      expect(state.emailAlerts, false);
      expect(state.userName, 'John Doe');
      expect(state.userRole, 'Administrator');
      expect(state.userId, '123');
      expect(state.profileImageUrl, 'https://example.com/image.jpg');
    });

    test('copyWith should create new state with updated fields', () {
      final state = ProfileState(
        pushNotifications: false,
        emailAlerts: true,
        userName: 'John Doe',
        userRole: 'User',
        userId: '123',
        profileImageUrl: 'url1',
      );

      final newState = state.copyWith(
        pushNotifications: true,
        userName: 'Jane Doe',
        userRole: 'Administrator',
      );

      expect(newState.pushNotifications, true);
      expect(newState.userName, 'Jane Doe');
      expect(newState.userRole, 'Administrator');
      expect(newState.emailAlerts, true);
      expect(newState.userId, '123');
      expect(newState.profileImageUrl, 'url1');
    });

    test('copyWith should keep original values when not specified', () {
      final state = ProfileState(
        pushNotifications: true,
        emailAlerts: false,
        userName: 'John Doe',
        userRole: 'Admin',
        userId: '123',
        profileImageUrl: 'url1',
      );

      final newState = state.copyWith(userName: 'Jane Doe');

      expect(newState.userName, 'Jane Doe');
      expect(newState.pushNotifications, true);
      expect(newState.emailAlerts, false);
      expect(newState.userRole, 'Admin');
      expect(newState.userId, '123');
      expect(newState.profileImageUrl, 'url1');
    });

    test('copyWith should toggle boolean fields', () {
      final state = ProfileState(
        pushNotifications: false,
        emailAlerts: false,
        userName: 'John Doe',
        userRole: 'User',
        userId: '123',
        profileImageUrl: 'url',
      );

      final withPush = state.copyWith(pushNotifications: true);
      expect(withPush.pushNotifications, true);
      expect(withPush.emailAlerts, false);

      final withBoth = withPush.copyWith(emailAlerts: true);
      expect(withBoth.pushNotifications, true);
      expect(withBoth.emailAlerts, true);
    });

    test('should handle empty strings', () {
      final state = ProfileState(
        pushNotifications: false,
        emailAlerts: true,
        userName: '',
        userRole: '',
        userId: '',
        profileImageUrl: '',
      );

      expect(state.userName, '');
      expect(state.userRole, '');
      expect(state.userId, '');
      expect(state.profileImageUrl, '');
    });

    test('should update profile image URL', () {
      final state = ProfileState(
        pushNotifications: false,
        emailAlerts: true,
        userName: 'John',
        userRole: 'User',
        userId: '123',
        profileImageUrl: 'old_url',
      );

      final newState = state.copyWith(
        profileImageUrl: 'https://new-image.com/photo.jpg',
      );

      expect(newState.profileImageUrl, 'https://new-image.com/photo.jpg');
      expect(newState.userName, 'John');
    });
  });

  group('Profile Notifier', () {
    test('initial state should have default values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final profile = container.read(profileProvider);

      expect(profile.pushNotifications, false);
      expect(profile.emailAlerts, true);
      expect(profile.userName, 'Jane Doe');
      expect(profile.userRole, 'Super Administrator');
      expect(profile.userId, '839201');
      expect(profile.profileImageUrl, isNotEmpty);
    });

    test('should toggle push notifications', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);

      expect(container.read(profileProvider).pushNotifications, false);

      notifier.togglePushNotifications();
      expect(container.read(profileProvider).pushNotifications, true);

      notifier.togglePushNotifications();
      expect(container.read(profileProvider).pushNotifications, false);
    });

    test('should toggle email alerts', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);

      expect(container.read(profileProvider).emailAlerts, true);

      notifier.toggleEmailAlerts();
      expect(container.read(profileProvider).emailAlerts, false);

      notifier.toggleEmailAlerts();
      expect(container.read(profileProvider).emailAlerts, true);
    });

    test('should update profile information', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(profileProvider.notifier);

      notifier.updateProfile('John Smith', 'Manager');

      final profile = container.read(profileProvider);
      expect(profile.userName, 'John Smith');
      expect(profile.userRole, 'Manager');
      expect(profile.userId, '839201'); // Should remain unchanged
    });
  });
}
