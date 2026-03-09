import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:uuid/uuid.dart';
import 'package:voice_first_admin/features/auth/data/models/auth_models.dart';
import 'package:voice_first_admin/features/auth/data/repositories/auth_repository.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';

// --- State ---
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final TokenModel? tokens;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.tokens,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    TokenModel? tokens,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      tokens: tokens ?? this.tokens,
    );
  }
}

// --- Provider ---
final authRepositoryProvider = Provider((ref) => AuthRepository());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<AuthState> {
  final _storage = const FlutterSecureStorage();

  @override
  AuthState build() {
    Future.microtask(() => _checkExistingAuth());
    return const AuthState();
  }

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> _checkExistingAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final accessToken = await _storage.read(key: 'access_token');
      if (accessToken != null && !JwtDecoder.isExpired(accessToken)) {
        final decodedToken = JwtDecoder.decode(accessToken);
        ref.read(profileProvider.notifier).setUserFromToken(decodedToken);
        state = state.copyWith(isLoading: false, isAuthenticated: true);
      } else {
        if (accessToken != null) {
          await logout();
        } else {
          state = state.copyWith(isLoading: false, isAuthenticated: false);
        }
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<DeviceModel> _getDeviceDetails() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    // Use the full string version (e.g. '1.0.0')
    String appVersion = packageInfo.version;

    String deviceId =
        await _storage.read(key: 'device_id') ?? const Uuid().v4();
    await _storage.write(key: 'device_id', value: deviceId);

    String deviceName = "Unknown";
    String deviceType = kIsWeb ? "Web" : "Mobile";
    String os = "Unknown";
    String osVersion = "Unknown";
    String manufacturer = "Unknown";
    String model = "Unknown";

    if (kIsWeb) {
      final webBrowserInfo = await deviceInfo.webBrowserInfo;
      deviceName = webBrowserInfo.browserName.name.toString();
      os = webBrowserInfo.platform ?? "Web OS";
      osVersion = webBrowserInfo.appVersion ?? "Unknown";
      manufacturer = webBrowserInfo.vendor ?? "Unknown";
      model = webBrowserInfo.userAgent ?? "Unknown";
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.name;
      os = "Android";
      osVersion = androidInfo.version.release;
      manufacturer = androidInfo.manufacturer;
      model = androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      deviceName = iosInfo.name;
      os = "iOS";
      osVersion = iosInfo.systemVersion;
      manufacturer = "Apple";
      model = iosInfo.model;
    }

    return DeviceModel(
      deviceId: deviceId,
      version: appVersion,
      deviceName: deviceName,
      deviceType: deviceType,
      os: os,
      osVersion: osVersion,
      manufacturer: manufacturer,
      model: model,
    );
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final deviceDetails = await _getDeviceDetails();

      final request = LoginRequestModel(
        email: email,
        password: password,
        clientType: kIsWeb ? "Web" : "Mobile",
        device: deviceDetails,
      );

      final tokens = await _repository.login(request);

      // Save securely
      await _storage.write(key: 'access_token', value: tokens.accessToken);
      await _storage.write(key: 'refresh_token', value: tokens.refreshToken);

      final decodedToken = JwtDecoder.decode(tokens.accessToken);
      debugPrint("DECODED JWT PAYLOAD: $decodedToken");

      ref.read(profileProvider.notifier).setUserFromToken(decodedToken);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        tokens: tokens,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    state = const AuthState(); // Reset state to completely logged out
  }
}
