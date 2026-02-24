import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_endpoints.dart';
import '../models/auth_models.dart';

class AuthRepository {
  Future<TokenModel> login(LoginRequestModel request) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/auth/login');
      debugPrint("Login Request: $uri");

      final response = await http.post(
        uri,
        headers: ApiEndpoints.defaultHeaders,
        body: jsonEncode(request.toJson()),
      );

      debugPrint("Login Status: ${response.statusCode}");
      debugPrint("Login Body: ${response.body}");

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = jsonDecode(response.body);
        if (body['data'] != null) {
          return TokenModel.fromJson(body['data']);
        } else {
          throw "Invalid response format: Missing data field";
        }
      } else {
        // Attempt to parse error message from API
        String errorMessage = "Login failed: ${response.statusCode}";
        try {
          final errorBody = jsonDecode(response.body);
          if (errorBody['message'] != null) {
            errorMessage = errorBody['message'];
          }
        } catch (_) {}
        throw errorMessage;
      }
    } catch (e) {
      debugPrint("Error in login: $e");
      rethrow;
    }
  }
}
