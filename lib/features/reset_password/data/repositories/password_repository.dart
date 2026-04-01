import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/reset_password/data/models/change_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/forgot_password_request.dart';
import 'package:voice_first_admin/features/reset_password/data/models/reset_password_request.dart';

class PasswordRepository {
  final Dio _dio;

  PasswordRepository(this._dio);
  Future<void> forgotPassword(ForgotPasswordRequest request) async {
    debugPrint('API REQUEST: POST /password/forgot');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');

    final response = await _dio.post(
      '/password/forgot',
      data: request.toJson(),
    );

    debugPrint(
      'API RESPONSE: POST /password/forgot -> ${response.statusCode} ${response.data}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(response.data);
    }
  }

  Future<void> resetPassword(ResetPasswordRequest request) async {
    debugPrint('API REQUEST: POST /password/reset');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');

    final response = await _dio.post('/password/reset', data: request.toJson());

    debugPrint(
      'API RESPONSE: POST /password/reset -> ${response.statusCode} ${response.data}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(response.data);
    }
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    debugPrint('API REQUEST: POST /password/change');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');

    final response = await _dio.post(
      '/password/change',
      data: request.toJson(),
    );

    debugPrint(
      'API RESPONSE: POST /password/change -> ${response.statusCode} ${response.data}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(response.data);
    }
  }
}

final passwordRepositoryProvider = Provider<PasswordRepository>((ref) {
  return PasswordRepository(ref.read(dioClientProvider));
});
