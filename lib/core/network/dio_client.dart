// lib/core/network/dio_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';

// Lock to prevent multiple simultaneous refresh calls
bool _isRefreshing = false;
Completer<String?> _refreshCompleter = Completer<String?>();

const _kAccessToken = 'access_token';
const _kRefreshToken = 'refresh_token';
const _kTokenExpiration = 'token_expiration';

final dioClientProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: ApiEndpoints.defaultHeaders,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip token injection for login / refresh calls
        if (options.extra['skipTokenRefresh'] == true) {
          return handler.next(options);
        }

        const storage = FlutterSecureStorage();
        String? token = await storage.read(key: _kAccessToken);
        final String? refreshToken = await storage.read(key: _kRefreshToken);
        final String? expirationTimeStr = await storage.read(
          key: _kTokenExpiration,
        );

        // Proactively refresh if token expires within 30 seconds
        if (token != null &&
            token.isNotEmpty &&
            refreshToken != null &&
            refreshToken.isNotEmpty &&
            expirationTimeStr != null) {
          try {
            final expirationTime = DateTime.parse(expirationTimeStr);
            final timeUntilExpiry = expirationTime
                .difference(DateTime.now())
                .inSeconds;

            if (timeUntilExpiry < 30) {
              debugPrint('Token expiring soon — refreshing proactively');
              token = await _refreshAccessToken(dio, refreshToken);
            }
          } catch (e) {
            debugPrint('Error checking token expiration: $e');
          }
        }

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },

      onError: (e, handler) async {
        handler.next(e);
      },
    ),
  );

  // Logging — never leak Authorization header value
  dio.interceptors.add(
    LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      logPrint: (obj) {
        final line = obj.toString();
        if (!line.contains('Authorization')) debugPrint(line);
      },
    ),
  );

  return dio;
});

/// Refreshes the access token using the stored refresh token.
/// Returns the new access token on success, or null on failure.
Future<String?> _refreshAccessToken(Dio dio, String refreshToken) async {
  const storage = FlutterSecureStorage();

  // If a refresh is already in progress, wait for it
  if (_isRefreshing) {
    return _refreshCompleter.future;
  }

  _isRefreshing = true;
  _refreshCompleter = Completer<String?>();

  try {
    final response = await dio.post(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {'skipTokenRefresh': true},
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
          response.data['data'] as Map<String, dynamic>? ?? response.data;

      final newAccessToken = data['accessToken'] as String?;
      final newRefreshToken = data['refreshToken'] as String?;
      final newExpiration = data['accessTokenExpiresAtUtc'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await storage.write(key: _kAccessToken, value: newAccessToken);

        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await storage.write(key: _kRefreshToken, value: newRefreshToken);
        }
        if (newExpiration != null && newExpiration.isNotEmpty) {
          await storage.write(key: _kTokenExpiration, value: newExpiration);
        }

        debugPrint('Access token refreshed successfully');
        _refreshCompleter.complete(newAccessToken);
        return newAccessToken;
      }
    }

    _refreshCompleter.complete(null);
    return null;
  } catch (e) {
    debugPrint('Token refresh failed: $e');
    _refreshCompleter.complete(null);
    return null;
  } finally {
    _isRefreshing = false;
  }
}
