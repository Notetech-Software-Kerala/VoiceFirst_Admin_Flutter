import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Program_management/models/create_program_request.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/models/program_filter.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';
import 'package:voice_first_admin/features/Program_management/models/update_program_request.dart';

class ProgramManagementService {
  static const String _path = '/program';

  //get all

  Future<PaginatedResponse<ProgramModel>> getAll(ProgramFilter filter) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$_path',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);
    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET programs): ${response.body}');
      throw Exception('Failed to load programs: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    debugPrint('API MESSAGE (GET programs): ${jsonBody['message']}');
    final data = jsonBody['data'];

    if (data is List) {
      final items = data
          .map((e) => ProgramModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedResponse(
        items: items,
        totalCount: items.length,
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        totalPages: 1,
      );
    }

    final items = (data['items'] as List? ?? [])
        .map((e) => ProgramModel.fromJson(e))
        .toList();

    return PaginatedResponse(
      items: items,
      totalCount: data['totalCount'] ?? items.length,
      pageNumber: data['pageNumber'] ?? filter.pageNumber,
      pageSize: data['pageSize'] ?? filter.pageSize,
      totalPages: data['totalPages'] ?? 1,
    );
  }

  //create

  Future<ProgramModel> create(CreateProgramRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');
    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(request.toJson()),
    );

    debugPrint('API RESPONSE: POST $url -> ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (create program): ${response.body}');
      throw Exception('Failed to create program: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    debugPrint('API MESSAGE (create program): ${jsonBody['message']}');
    return ProgramModel.fromJson(jsonBody['data']);
  }
  //update

  Future<ProgramModel> update(int id, UpdateProgramRequest request) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    final body = request.toJson();

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    debugPrint('API RESPONSE: PATCH $url -> ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API ERROR BODY (update program): ${response.body}');
      throw Exception('Failed to update program: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    debugPrint('API MESSAGE (update program): ${jsonBody['message']}');
    return ProgramModel.fromJson(jsonBody['data']);
  }

  //delete

  Future<ProgramModel> delete(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint('API RESPONSE: DELETE $url -> ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API ERROR BODY (delete program): ${response.body}');
      throw Exception('Failed to delete program: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    debugPrint('API MESSAGE (delete program): ${jsonBody['message']}');
    return ProgramModel.fromJson(jsonBody['data']);
  }

  //bulk delete
  Future<void> bulkDelete(List<int> ids) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/bulk-delete');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'ids': ids}),
    );

    debugPrint(
      'API RESPONSE: POST $url (bulk delete) -> ${response.statusCode}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API ERROR BODY (bulk delete programs): ${response.body}');
      throw Exception('Failed to bulk delete programs: ${response.statusCode}');
    }
  }

  //recover

  Future<ProgramModel> recover(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program/recover/$id');

    debugPrint('API REQUEST: PATCH $url');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint('API RESPONSE: PATCH $url (recover) -> ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API ERROR BODY (recover program): ${response.body}');
      throw Exception('Failed to recover program: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    debugPrint('API MESSAGE (recover program): ${jsonBody['message']}');

    return ProgramModel.fromJson(jsonBody['data']);
  }
}
