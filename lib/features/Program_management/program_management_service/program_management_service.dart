import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpints.dart';
import 'package:voice_first_admin/features/Program_management/models/program_management_model.dart';
import 'package:voice_first_admin/features/Program_management/models/program_filter.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';

class ProgramManagementService {
  static const String _path = '/program';

  Future<PaginatedResponse<ProgramModel>> getAll(ProgramFilter filter) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$_path',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load programs: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
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

    final items = (data['items'] as List)
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

  Future<ProgramModel> create(ProgramModel program) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(program.toCreateJson())}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(program.toCreateJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create program: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    return ProgramModel.fromJson(jsonBody['data']);
  }

  Future<ProgramModel> update(
    int id,
    ProgramModel program, {
    bool updateBasic = false,
    bool updateActions = false,
    bool? updateActive,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    final body = program.toUpdateJson(
      updateBasic: updateBasic,
      updateActions: updateActions,
      updateActive: updateActive,
    );

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update program: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    return ProgramModel.fromJson(jsonBody['data']);
  }

  //delete

  Future<void> delete(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete program: ${response.statusCode}');
    }
  }

  Future<void> bulkDelete(List<int> ids) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/bulk-delete');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to bulk delete programs: ${response.statusCode}');
    }
  }

  Future<void> recover(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/program/recover/$id');

    debugPrint('API REQUEST: PATCH $url');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to recover program: ${response.statusCode}');
    }
  }
}
