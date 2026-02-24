import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/reset_password/data/models/change_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/forgot_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/reset_password_request.dart';

class PasswordService {
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/auth/forgot-password');

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
      throw Exception('Failed to send OTP');
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/auth/reset-password');

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
      throw Exception('Failed to reset password');
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/auth/change-password');

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
      throw Exception('Failed to change password');
    }
  }
}
