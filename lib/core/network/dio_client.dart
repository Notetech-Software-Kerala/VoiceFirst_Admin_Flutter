// // lib/Core/Services/api_client.dart
// import 'dart:async';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:voice_first_admin/core/config/api_endpints.dart';

// class ApiClient {
//   static final ApiClient _i = ApiClient._internal();
//   factory ApiClient() => _i;

//   late final Dio dio;

//   // Token refresh lock to avoid multiple simultaneous refresh calls
//   bool _isRefreshing = false;
//   final Completer<String?> _refreshCompleter = Completer<String?>();

//   ApiClient._internal() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.baseUrl,
//         connectTimeout: const Duration(seconds: 15),
//         receiveTimeout: const Duration(seconds: 15),
//         headers: ApiEndpoints.defaultHeaders,
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           const storage = FlutterSecureStorage();

//           // Per-request override: Options(extra: {'auth': 'company'|'user'})
//           final scope = options.extra['auth'] as String?;
//           String? token;
//           String? refreshToken;
//           String? expirationTimeStr;

//           if (scope == 'company') {
//             token = await storage.read(key: 'company_access_token');
//             refreshToken = await storage.read(key: 'company_refresh_token');
//             expirationTimeStr = await storage.read(
//               key: 'company_token_expiration',
//             );
//           } else if (scope == 'user') {
//             token = await storage.read(key: 'user_access_token');
//             refreshToken = await storage.read(key: 'user_refresh_token');
//             expirationTimeStr = await storage.read(
//               key: 'user_token_expiration',
//             );
//           } else {
//             // Default: prefer company, then active, then user
//             token = await storage.read(key: 'company_access_token');
//             refreshToken = await storage.read(key: 'company_refresh_token');
//             expirationTimeStr = await storage.read(
//               key: 'company_token_expiration',
//             );

//             if (token == null || token.isEmpty) {
//               token = await storage.read(key: 'active_access_token');
//               refreshToken = await storage.read(key: 'active_refresh_token');
//               expirationTimeStr = await storage.read(
//                 key: 'active_token_expiration',
//               );
//             }

//             if (token == null || token.isEmpty) {
//               token = await storage.read(key: 'user_access_token');
//               refreshToken = await storage.read(key: 'user_refresh_token');
//               expirationTimeStr = await storage.read(
//                 key: 'user_token_expiration',
//               );
//             }
//           }

//           // Check if token is about to expire (within 30 seconds)
//           if (token != null &&
//               token.isNotEmpty &&
//               refreshToken != null &&
//               refreshToken.isNotEmpty &&
//               expirationTimeStr != null) {
//             try {
//               final expirationTime = DateTime.parse(expirationTimeStr);
//               final now = DateTime.now();
//               final timeUntilExpiry = expirationTime.difference(now).inSeconds;

//               // If token expires within 30 seconds, refresh it
//               if (timeUntilExpiry < 30) {
//                 token = await _refreshAccessToken(scope, token, refreshToken);
//               }
//             } catch (e) {
//               debugPrint('Error checking token expiration: $e');
//             }
//           }

//           if (token != null && token.isNotEmpty) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }

//           handler.next(options);
//         },

//         onError: (e, handler) async {
//           // If token was refreshed and request failed due to 401,
//           // let it propagate (token refresh was already attempted in onRequest)
//           handler.next(e);
//         },
//       ),
//     );

//     // Logging (don’t leak Authorization)
//     dio.interceptors.add(
//       LogInterceptor(
//         request: true,
//         requestBody: true,
//         responseBody: true,
//         logPrint: (obj) {
//           final line = obj.toString();
//           if (!line.contains('Authorization')) debugPrint(line);
//         },
//       ),
//     );
//   }

//   /// Refresh the access token using the refresh token.
//   /// Returns the new access token if successful, otherwise null.
//   Future<String?> _refreshAccessToken(
//     String? scope,
//     String? currentToken,
//     String? refreshToken,
//   ) async {
//     const storage = FlutterSecureStorage();

//     // If already refreshing, wait for the result
//     if (_isRefreshing) {
//       return _refreshCompleter.future;
//     }

//     _isRefreshing = true;

//     try {
//       // Determine which endpoint and storage keys to use
//       String refreshEndpoint = '/api/auth/refresh';
//       String tokenKey = 'user_access_token';
//       String refreshTokenKey = 'user_refresh_token';
//       String expirationKey = 'user_token_expiration';

//       if (scope == 'company') {
//         tokenKey = 'company_access_token';
//         refreshTokenKey = 'company_refresh_token';
//         expirationKey = 'company_token_expiration';
//       } else if (scope == 'user') {
//         tokenKey = 'user_access_token';
//         refreshTokenKey = 'user_refresh_token';
//         expirationKey = 'user_token_expiration';
//       } else {
//         // Default scope handling
//         tokenKey = 'company_access_token';
//         refreshTokenKey = 'company_refresh_token';
//         expirationKey = 'company_token_expiration';
//       }

//       // Make the refresh token API call
//       final response = await dio.post(
//         refreshEndpoint,
//         data: {'refresh_token': refreshToken},
//         options: Options(
//           headers: {'Content-Type': 'application/json'},
//           extra: {'skipTokenRefresh': true}, // Avoid recursive refresh
//         ),
//       );

//       if (response.statusCode == 200) {
//         final newAccessToken = response.data['access_token'] as String?;
//         final newRefreshToken = response.data['refresh_token'] as String?;
//         final expiresIn = response.data['expires_in'] as int?;

//         if (newAccessToken != null && newAccessToken.isNotEmpty) {
//           // Calculate expiration time
//           final expirationTime = DateTime.now().add(
//             Duration(seconds: expiresIn ?? 3600),
//           );

//           // Store the new tokens
//           await storage.write(key: tokenKey, value: newAccessToken);
//           if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
//             await storage.write(key: refreshTokenKey, value: newRefreshToken);
//           }
//           await storage.write(
//             key: expirationKey,
//             value: expirationTime.toIso8601String(),
//           );

//           debugPrint('Access token refreshed successfully');
//           _refreshCompleter.complete(newAccessToken);
//           _isRefreshing = false;
//           return newAccessToken;
//         }
//       }
//     } catch (e) {
//       debugPrint('Error refreshing access token: $e');
//       _refreshCompleter.complete(null);
//     } finally {
//       if (!_refreshCompleter.isCompleted) {
//         _refreshCompleter.complete(null);
//       }
//       _isRefreshing = false;
//     }

//     return null;
//   }
// }
