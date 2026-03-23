import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/reset_password/data/models/change_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/forgot_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/reset_password_request.dart';

class PasswordService {
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/password/forgot');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(request.toJson()),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/password/reset');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(request.toJson()),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/password/change');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');

    // Try to attach an Authorization header if an access token is available.
    // Prefer the primary auth token ('access_token') used by the auth flow.
    final storage = const FlutterSecureStorage();
    String? token;
    String? usedKey;

    token = await storage.read(key: 'access_token');
    if (token != null && token.isNotEmpty) {
      usedKey = 'access_token';
    } else {
      token = await storage.read(key: 'company_access_token');
      if (token != null && token.isNotEmpty) {
        usedKey = 'company_access_token';
      } else {
        token = await storage.read(key: 'active_access_token');
        if (token != null && token.isNotEmpty) {
          usedKey = 'active_access_token';
        } else {
          token = await storage.read(key: 'user_access_token');
          if (token != null && token.isNotEmpty) usedKey = 'user_access_token';
        }
      }
    }

    final headers = Map<String, String>.from(ApiEndpoints.defaultHeaders);
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
      debugPrint('changePassword: attaching Authorization from key="$usedKey"');
    } else {
      debugPrint(
        'changePassword: no access token found; calling without Authorization',
      );
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(request.toJson()),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(response.body);
    }
  }
}
