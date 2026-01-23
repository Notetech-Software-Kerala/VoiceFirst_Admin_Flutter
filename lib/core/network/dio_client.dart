// lib/Core/Services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._internal();
  factory ApiClient() => _i;

  late final Dio dio;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        // baseUrl: ApiEndpoints.baseUrl, // e.g. http://59.94.176.2:8022/api
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          const storage = FlutterSecureStorage();

          // Per-request override: Options(extra: {'auth': 'company'|'user'})
          final scope = options.extra['auth'] as String?;
          String? token;

          if (scope == 'company') {
            token = await storage.read(key: 'company_access_token');
          } else if (scope == 'user') {
            token = await storage.read(key: 'user_access_token');
          } else {
            // Default: prefer company, then active, then user
            token =
                await storage.read(key: 'company_access_token') ??
                await storage.read(key: 'active_access_token') ??
                await storage.read(key: 'user_access_token');
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },

        onError: (e, handler) async {
          // Optional: retry once with company token if 401 and not already company
          if (e.response?.statusCode == 401) {
            try {
              final req = e.requestOptions;
              final usedScope = req.extra['auth'] as String?;
              if (usedScope != 'company') {
                const storage = FlutterSecureStorage();
                final companyToken = await storage.read(
                  key: 'company_access_token',
                );
                if (companyToken != null && companyToken.isNotEmpty) {
                  final opts = Options(
                    method: req.method,
                    headers: Map<String, dynamic>.from(req.headers)
                      ..['Authorization'] = 'Bearer $companyToken',
                    responseType: req.responseType,
                    contentType: req.contentType,
                    validateStatus: req.validateStatus,
                  );
                  final clone = await dio.request<dynamic>(
                    req.path,
                    data: req.data,
                    queryParameters: req.queryParameters,
                    options: opts,
                  );
                  return handler.resolve(clone);
                }
              }
            } catch (_) {
              // fall through to original error
            }
          }
          handler.next(e);
        },
      ),
    );

    // Logging (don’t leak Authorization)
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
  }
}
