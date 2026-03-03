import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/api_endpoints.dart';
import '../models/user_filter_model.dart';

class UserRepository {
  Future<Map<String, dynamic>> getUsers(UserFilterModel filter) async {
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/employee',
      ).replace(queryParameters: filter.toQueryParams());

      debugPrint("Fetching Users: $uri");

      final response = await http.get(uri);

      debugPrint("Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to load: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      debugPrint("Error in getUsers: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/employee');
      debugPrint("Creating User: $uri");

      final response = await http.post(
        uri,
        headers: ApiEndpoints.defaultHeaders,
        body: jsonEncode(data),
      );

      debugPrint(
        "Create Status: ${response.statusCode} - Body: ${response.body}",
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to create user: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      debugPrint("Error in createUser: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/employee/$id');
      debugPrint("Updating User: $uri");

      final response = await http.patch(
        uri,
        headers: ApiEndpoints.defaultHeaders,
        body: jsonEncode(data),
      );

      debugPrint(
        "Update Status: ${response.statusCode} - Body: ${response.body}",
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to update user: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      debugPrint("Error in updateUser: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      const storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      final Map<String, String> headers = {
        ...ApiEndpoints.defaultHeaders,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/employee/$id');
      debugPrint("Deleting User: $uri");

      final response = await http.delete(uri, headers: headers);

      debugPrint(
        "Delete Status: ${response.statusCode} - Body: ${response.body}",
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw "Failed to delete user: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      debugPrint("Error in deleteUser: $e");
      rethrow;
    }
  }

  Future<void> recoverUser(int id) async {
    try {
      const storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      final Map<String, String> headers = {
        ...ApiEndpoints.defaultHeaders,
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      final uri = Uri.parse('${ApiEndpoints.baseUrl}/employee/recover/$id');
      debugPrint("Recovering User: $uri");

      // Assuming it's a PATCH or POST. Based on typical REST for recovering, often PATCH or PUT.
      // The user just provided the URL, so we'll try PATCH with empty body first, which is standard.
      final response = await http.patch(uri, headers: headers);

      debugPrint(
        "Recover Status: ${response.statusCode} - Body: ${response.body}",
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw "Failed to recover user: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      debugPrint("Error in recoverUser: $e");
      rethrow;
    }
  }
}
