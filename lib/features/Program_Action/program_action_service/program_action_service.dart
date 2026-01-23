import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpints.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_filter.dart';
import 'package:voice_first_admin/features/Program_Action/models/program_action_model.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';

class ProgramActionService {
  ProgramActionService();

  Future<PaginatedResponse<ProgramActionModel>> getAll(
    ProgramActionFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/program-action',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load program actions: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    final data = json['data'];

    return PaginatedResponse(
      items: (data['items'] as List)
          .map((e) => ProgramActionModel.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'],
      totalPages: data['totalPages'],
    );
  }

  /// Lightweight lookup list for selectors (non-paginated)
  Future<List<ProgramActionModel>> getLookup() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program-action/lookup');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to load program action lookup: ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);
    final list = body['data'] as List<dynamic>? ?? <dynamic>[];
    return list
        .map((e) => ProgramActionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProgramActionModel> create(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program-action');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"actionName":"$name"}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'actionName': name}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to create program action: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);
    return ProgramActionModel.fromJson(json['data']);
  }

  Future<ProgramActionModel> updateAction(
    int id, {
    String? name,
    bool? active,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program-action/$id');

    // Build request body with only provided fields
    final requestBody = <String, dynamic>{};
    if (name != null) requestBody['actionName'] = name;
    if (active != null) requestBody['active'] = active;

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(requestBody)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(requestBody),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update program action: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);
    return ProgramActionModel.fromJson(json['data']);
  }

  Future<void> recover(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program-action/recover/$id');

    debugPrint('API REQUEST: PATCH $url');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to recover program action: ${response.statusCode}',
      );
    }
  }

  Future<void> delete(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program-action/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete program action: ${response.statusCode}',
      );
    }
  }

  Future<void> bulkDelete(List<int> ids) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program-action/bulk-delete');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to bulk delete program actions: ${response.statusCode}',
      );
    }
  }
}
