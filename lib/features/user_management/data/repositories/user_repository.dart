import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
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
}
