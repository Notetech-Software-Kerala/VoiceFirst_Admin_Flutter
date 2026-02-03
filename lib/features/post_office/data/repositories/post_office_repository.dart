import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_endpints.dart';

class PostOfficeRepository {
  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<Map<String, dynamic>> getPostOffices({
    required int pageNumber,
    required int limit,
    String? searchText,
  }) async {
    try {
      final queryParams = {
        'PageNumber': pageNumber.toString(),
        'Limit': limit.toString(),
        'SortOrder': 'Desc',
        'Deleted': 'false',
        if (searchText != null && searchText.isNotEmpty)
          'SearchText': searchText,
      };

      // Robust URI construction
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/post-office',
      ).replace(queryParameters: queryParams);

      debugPrint("Fetching Post Offices: $uri");

      final response = await http.get(uri);

      debugPrint("Response Status: ${response.statusCode}");
      // debugPrint("Response Body: ${response.body}"); // Uncomment if needed

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to load: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      debugPrint("Error in getPostOffices: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPostOfficeById(int id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office/$id');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to load post office details";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createPostOffice(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office');
      final response = await http.post(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );

      if (!_isSuccess(response)) {
        throw "Create failed: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updatePostOffice(int id, Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office/$id');
      final response = await http.patch(
        uri,
        headers: _headers,
        body: jsonEncode(data),
      );

      if (!_isSuccess(response)) {
        throw "Update failed: ${response.statusCode} ${response.body}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePostOffice(int id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office/$id');
      final response = await http.delete(uri);

      if (!_isSuccess(response)) {
        throw "Delete failed: ${response.statusCode}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getCountries() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/country/lookup');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      } else {
        throw "Failed to load countries";
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- DIVISION LOOKUPS ---

  Future<List<dynamic>> getDivisionOne(String countryId) async {
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/division/one/lookup/$countryId',
      );
      final response = await http.get(uri);

      if (_isSuccess(response)) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      }
      throw "Failed to load Division 1";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getDivisionTwo(String divOneId) async {
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/division/two/lookup/$divOneId',
      );
      final response = await http.get(uri);

      if (_isSuccess(response)) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      }
      throw "Failed to load Division 2";
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getDivisionThree(String divTwoId) async {
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/division/three/lookup/$divTwoId',
      );
      final response = await http.get(uri);

      if (_isSuccess(response)) {
        final json = jsonDecode(response.body);
        return json['data'] ?? [];
      }
      throw "Failed to load Division 3";
    } catch (e) {
      rethrow;
    }
  }

  bool _isSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return true;
    }
    return false;
  }
}
