import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<TokenModel> login(LoginRequestModel request) async {
    try {
      debugPrint("=== STARTING DIO LOGIN REQUEST ===");
      debugPrint("Login Request URI: /auth/login");
      debugPrint("Login Request Body:");
      debugPrint(request.toJson().toString());

      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
        options: Options(extra: {'skipTokenRefresh': true}),
      );

      debugPrint("Login Status: ${response.statusCode}");
      debugPrint("Login Data: ${response.data}");

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final body = response.data as Map<String, dynamic>;
        if (body['data'] != null) {
          return TokenModel.fromJson(body['data']);
        } else {
          throw "Invalid response format: Missing data field";
        }
      } else {
        throw "Login failed: ${response.statusCode}";
      }
    } on DioException catch (e) {
      debugPrint("Dio Error in login: ${e.response?.data}");
      String errorMessage = "Login failed: ${e.response?.statusCode}";
      if (e.response?.data != null && e.response?.data is Map) {
        if (e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      }
      throw errorMessage;
    } catch (e) {
      debugPrint("Error in login: $e");
      rethrow;
    }
  }
}
