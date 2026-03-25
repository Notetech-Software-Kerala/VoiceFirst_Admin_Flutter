// lib/core/network/dio_client.dart
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';

// Token refresh lock to avoid multiple simultaneous refresh calls
bool _isRefreshing = false;
Completer<String?> _refreshCompleter = Completer<String?>();

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
        // Skip token injection for refresh token calls to avoid recursive loop
        if (options.extra['skipTokenRefresh'] == true) {
          return handler.next(options);
        }

        const storage = FlutterSecureStorage();

        // Per-request override: Options(extra: {'auth': 'company'|'user'})
        final scope = options.extra['auth'] as String?;
        String? token;
        String? refreshToken;
        String? expirationTimeStr;

        if (scope == 'company') {
          token = await storage.read(key: 'company_access_token');
          refreshToken = await storage.read(key: 'company_refresh_token');
          expirationTimeStr = await storage.read(
            key: 'company_token_expiration',
          );
        } else if (scope == 'user') {
          token = await storage.read(key: 'user_access_token');
          refreshToken = await storage.read(key: 'user_refresh_token');
          expirationTimeStr = await storage.read(
            key: 'user_token_expiration',
          );
        } else {
          // Default: prefer company, then active, then user
          token = await storage.read(key: 'company_access_token');
          refreshToken = await storage.read(key: 'company_refresh_token');
          expirationTimeStr = await storage.read(
            key: 'company_token_expiration',
          );

          if (token == null || token.isEmpty) {
            token = await storage.read(key: 'active_access_token');
            refreshToken = await storage.read(key: 'active_refresh_token');
            expirationTimeStr = await storage.read(
              key: 'active_token_expiration',
            );
          }

          if (token == null || token.isEmpty) {
            token = await storage.read(key: 'user_access_token');
            refreshToken = await storage.read(key: 'user_refresh_token');
            expirationTimeStr = await storage.read(
              key: 'user_token_expiration',
            );
          }
        }

        // Check if token is about to expire (within 30 seconds)
        if (token != null &&
            token.isNotEmpty &&
            refreshToken != null &&
            refreshToken.isNotEmpty &&
            expirationTimeStr != null) {
          try {
            final expirationTime = DateTime.parse(expirationTimeStr);
            final now = DateTime.now();
            final timeUntilExpiry = expirationTime.difference(now).inSeconds;

            // If token expires within 30 seconds, refresh it
            if (timeUntilExpiry < 30) {
              token = await _refreshAccessToken(dio, scope, token, refreshToken);
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
        // If token was refreshed and request failed due to 401,
        // let it propagate (token refresh was already attempted in onRequest)
        handler.next(e);
      },
    ),
  );

  // Logging (don't leak Authorization)
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

/// Refresh the access token using the refresh token.
/// Returns the new access token if successful, otherwise null.
Future<String?> _refreshAccessToken(
  Dio dio,
  String? scope,
  String? currentToken,
  String? refreshToken,
) async {
  const storage = FlutterSecureStorage();

  // If already refreshing, wait for the existing refresh to complete
  if (_isRefreshing) {
    return _refreshCompleter.future;
  }

  _isRefreshing = true;
  _refreshCompleter = Completer<String?>(); // reset for reuse

  try {
    // Determine which endpoint and storage keys to use
    const refreshEndpoint = '/api/auth/refresh';
    String tokenKey;
    String refreshTokenKey;
    String expirationKey;

    if (scope == 'company') {
      tokenKey = 'company_access_token';
      refreshTokenKey = 'company_refresh_token';
      expirationKey = 'company_token_expiration';
    } else if (scope == 'user') {
      tokenKey = 'user_access_token';
      refreshTokenKey = 'user_refresh_token';
      expirationKey = 'user_token_expiration';
    } else {
      // Default scope handling
      tokenKey = 'company_access_token';
      refreshTokenKey = 'company_refresh_token';
      expirationKey = 'company_token_expiration';
    }

    // Make the refresh token API call
    final response = await dio.post(
      refreshEndpoint,
      data: {'refreshToken': refreshToken},
      options: Options(
        headers: {'Content-Type': 'application/json'},
        extra: {'skipTokenRefresh': true}, // Avoid recursive refresh
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = 
          response.data['data'] as Map<String, dynamic>? ?? response.data;

      final newAccessToken = responseData['accessToken'] as String?;
      final newRefreshToken = responseData['refreshToken'] as String?;
      final expirationStr = responseData['accessTokenExpiresAtUtc'] as String?;

      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        // Store the new tokens
        await storage.write(key: tokenKey, value: newAccessToken);
        
        if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
          await storage.write(key: refreshTokenKey, value: newRefreshToken);
        }
        
        if (expirationStr != null && expirationStr.isNotEmpty) {
          await storage.write(key: expirationKey, value: expirationStr);
        }

        debugPrint('Access token refreshed successfully');
        _refreshCompleter.complete(newAccessToken);
        return newAccessToken;
      }
    }

    _refreshCompleter.complete(null);
    return null;
  } catch (e) {
    debugPrint('Error refreshing access token: $e');
    _refreshCompleter.complete(null);
    return null;
  } finally {
    _isRefreshing = false;
  }
}
