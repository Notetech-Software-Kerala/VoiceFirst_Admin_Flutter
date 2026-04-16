import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/program_actions/data/models/program_action_filter.dart';
import 'package:voice_first_admin/features/program_actions/data/models/program_action_model.dart';
import 'package:voice_first_admin/features/program_actions/data/models/paginated_response.dart';

class ProgramActionRepository {
  final Dio _dio;

  ProgramActionRepository(this._dio);

  Future<PaginatedResponse<ProgramActionModel>> getAll(
    ProgramActionFilter filter,
  ) async {
    debugPrint('API REQUEST: GET /program-action');
    final response = await _dio.get(
      '/program-action',
      queryParameters: filter.toQueryParams(),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to load program actions: ${response.statusCode}');
    }

    final json = response.data as Map<String, dynamic>;
    final data = json['data'];

    return PaginatedResponse(
      items: (data['items'] as List)
          .map((e) => ProgramActionModel.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'] ?? data['limit'],
      totalPages: data['totalPages'],
    );
  }

  Future<List<ProgramActionModel>> getLookup() async {
    debugPrint('API REQUEST: GET /program-action/lookup');
    final response = await _dio.get('/program-action/lookup');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        'Failed to load program action lookup: ${response.statusCode}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>? ?? <dynamic>[];
    return list
        .map((e) => ProgramActionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProgramActionModel> create(String name) async {
    debugPrint('API REQUEST: POST /program-action');
    debugPrint('Request Body: {"actionName":"$name"}');

    final response = await _dio.post(
      '/program-action',
      data: {'actionName': name},
    );

    if (response.statusCode == null ||
        (response.statusCode! < 200 || response.statusCode! >= 300)) {
      throw Exception(
        'Failed to create program action: ${response.statusCode}',
      );
    }

    final json = response.data as Map<String, dynamic>;
    return ProgramActionModel.fromJson(json['data']);
  }

  Future<ProgramActionModel> updateAction(
    int id, {
    String? name,
    bool? active,
  }) async {
    final requestBody = <String, dynamic>{};
    if (name != null) requestBody['actionName'] = name;
    if (active != null) requestBody['active'] = active;

    debugPrint('API REQUEST: PATCH /program-action/$id');
    debugPrint('Request Body: ${jsonEncode(requestBody)}');

    final response = await _dio.patch('/program-action/$id', data: requestBody);

    if (response.statusCode == null || response.statusCode! != 200) {
      throw Exception(
        'Failed to update program action: ${response.statusCode}',
      );
    }

    final json = response.data as Map<String, dynamic>;
    return ProgramActionModel.fromJson(json['data']);
  }

  Future<void> recover(int id) async {
    debugPrint('API REQUEST: PATCH /program-action/recover/$id');
    final response = await _dio.patch('/program-action/recover/$id');

    if (response.statusCode == null || response.statusCode! != 200) {
      throw Exception(
        'Failed to recover program action: ${response.statusCode}',
      );
    }
  }

  Future<void> delete(int id) async {
    debugPrint('API REQUEST: DELETE /program-action/$id');
    final response = await _dio.delete('/program-action/$id');

    if (response.statusCode == null || response.statusCode! != 200) {
      throw Exception(
        'Failed to delete program action: ${response.statusCode}',
      );
    }
  }

  Future<void> bulkDelete(List<int> ids) async {
    debugPrint('API REQUEST: POST /program-action/bulk-delete');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await _dio.post(
      '/program-action/bulk-delete',
      data: {'ids': ids},
    );

    if (response.statusCode == null || response.statusCode! != 200) {
      throw Exception(
        'Failed to bulk delete program actions: ${response.statusCode}',
      );
    }
  }
}

final programActionRepositoryProvider = Provider<ProgramActionRepository>((ref) {
  return ProgramActionRepository(ref.read(dioClientProvider));
});
