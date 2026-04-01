import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/program_management/data/models/create_program_request.dart';
import 'package:voice_first_admin/features/program_management/data/models/program_management_model.dart';
import 'package:voice_first_admin/features/program_management/data/models/program_filter.dart';
import 'package:voice_first_admin/features/program_action/data/models/paginated_response.dart';
import 'package:voice_first_admin/features/program_management/data/models/update_program_request.dart';

class ProgramManagementRepository {
  static const String _path = '/program';

  final Dio _dio;
  ProgramManagementRepository(this._dio);

  Future<PaginatedResponse<ProgramModel>> getAll(ProgramFilter filter) async {
    debugPrint('API REQUEST: GET $_path');
    final response = await _dio.get(
      _path,
      queryParameters: filter.toQueryParams(),
    );

    debugPrint('API RESPONSE: GET $_path -> ${response.statusCode}');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (GET programs): ${response.data}');
      throw Exception('Failed to load programs: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;
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
        pageSize: filter.limit,
        totalPages: 1,
      );
    }

    final items = (data['items'] as List? ?? [])
        .map((e) => ProgramModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse(
      items: items,
      totalCount: data['totalCount'] ?? items.length,
      pageNumber: data['pageNumber'] ?? filter.pageNumber,
      pageSize: data['pageSize'] ?? data['limit'] ?? filter.limit,
      totalPages: data['totalPages'] ?? 1,
    );
  }

  Future<ProgramModel> create(CreateProgramRequest request) async {
    debugPrint('API REQUEST: POST $_path');
    debugPrint('Request Body: ${jsonEncode(request.toJson())}');
    final response = await _dio.post(_path, data: request.toJson());

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (create program): ${response.data}');
      throw Exception('Failed to create program: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;
    debugPrint('API MESSAGE (create program): ${jsonBody['message']}');
    return ProgramModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<ProgramModel> update(int id, UpdateProgramRequest request) async {
    debugPrint('API REQUEST: PATCH $_path/$id');
    final body = request.toJson();
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await _dio.patch('$_path/$id', data: body);

    debugPrint('API RESPONSE: PATCH $_path/$id -> ${response.statusCode}');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (update program): ${response.data}');
      throw Exception('Failed to update program: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;
    debugPrint('API MESSAGE (update program): ${jsonBody['message']}');
    return ProgramModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<ProgramModel> delete(int id) async {
    debugPrint('API REQUEST: DELETE $_path/$id');
    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (delete program): ${response.data}');
      throw Exception('Failed to delete program: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;
    debugPrint('API MESSAGE (delete program): ${jsonBody['message']}');
    return ProgramModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<void> bulkDelete(List<int> ids) async {
    debugPrint('API REQUEST: POST $_path/bulk-delete');
    debugPrint('Request Body: {"ids":$ids}');
    final response = await _dio.post('$_path/bulk-delete', data: {'ids': ids});

    debugPrint(
      'API RESPONSE: POST $_path (bulk delete) -> ${response.statusCode}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (bulk delete programs): ${response.data}');
      throw Exception('Failed to bulk delete programs: ${response.statusCode}');
    }
  }

  Future<ProgramModel> recover(int id) async {
    debugPrint('API REQUEST: PATCH /program/recover/$id');
    final response = await _dio.patch('/program/recover/$id');

    debugPrint(
      'API RESPONSE: PATCH /program/recover/$id -> ${response.statusCode}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (recover program): ${response.data}');
      throw Exception('Failed to recover program: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;
    debugPrint('API MESSAGE (recover program): ${jsonBody['message']}');

    return ProgramModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }
}

final programManagementRepositoryProvider = Provider<ProgramManagementRepository>((
  ref,
) {
  return ProgramManagementRepository(ref.read(dioClientProvider));
});
