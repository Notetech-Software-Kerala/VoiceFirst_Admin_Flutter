import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_filter.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/paginated_response.dart';

class CustomFieldService {
  static const String _path = '/user-custom-field';

  // ─── CREATE ───────────────────────────────────────────────────────────────
  Future<(CustomFieldModel, String)> create(CustomFieldModel field) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');
    final body = jsonEncode(field.toCreateJson());

    debugPrint('API REQUEST: POST $url\nBody: $body');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: body,
    );

    debugPrint('API RESPONSE: POST $url -> ${response.statusCode} ${response.body}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final message = jsonBody['message']?.toString() ??
        (response.statusCode == 200 || response.statusCode == 201
            ? 'Custom field created successfully'
            : 'Failed to create custom field');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (CustomFieldModel.fromJson(data), message);
  }

  // ─── READ ALL ─────────────────────────────────────────────────────────────
  Future<PaginatedResponse<CustomFieldModel>> getAll(
    CustomFieldFilter filter,
  ) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$_path')
        .replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load custom fields';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => CustomFieldModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<CustomFieldModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  // ─── READ ONE ─────────────────────────────────────────────────────────────
  Future<CustomFieldModel> getById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $url -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load custom field';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return CustomFieldModel.fromJson(data);
  }

  // ─── UPDATE ───────────────────────────────────────────────────────────────
  Future<CustomFieldModel> update({
    required int id,
    required CustomFieldModel field,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');
    final body = jsonEncode(field.toUpdateJson());

    debugPrint('API REQUEST: PATCH $url\nBody: $body');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: body,
    );

    debugPrint('API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to update custom field';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return CustomFieldModel.fromJson(data);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<void> delete(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint('API RESPONSE: DELETE $url -> ${response.statusCode} ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          jsonBody['message']?.toString() ?? 'Failed to delete custom field';
      throw Exception(message);
    }
  }
}
