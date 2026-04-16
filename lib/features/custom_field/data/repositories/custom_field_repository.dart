import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_filter.dart';
import 'package:voice_first_admin/features/custom_field/data/models/custom_field_model.dart';
import 'package:voice_first_admin/features/program_action/data/models/paginated_response.dart';

class CustomFieldRepository {
  final Dio _dio;
  CustomFieldRepository(this._dio);

  static const String _path = '/user-custom-field';

  // ─── CREATE ───────────────────────────────────────────────────────────────
  Future<(CustomFieldModel, String)> create(CustomFieldModel field) async {
    debugPrint('API REQUEST: POST $_path');
    final response = await _dio.post(_path, data: field.toCreateJson());

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;
    final message = jsonBody['message']?.toString() ?? 'Custom field created successfully';

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (CustomFieldModel.fromJson(data), message);
  }

  // ─── READ ALL ─────────────────────────────────────────────────────────────
  Future<PaginatedResponse<CustomFieldModel>> getAll(CustomFieldFilter filter) async {
    debugPrint('API REQUEST: GET $_path');
    final response = await _dio.get(_path, queryParameters: filter.toQueryParams());

    debugPrint('API RESPONSE: GET $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = jsonBody['message']?.toString() ?? 'Failed to load custom fields';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson.map((e) => CustomFieldModel.fromJson(e as Map<String, dynamic>)).toList();

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
    debugPrint('API REQUEST: GET $_path/$id');
    final response = await _dio.get('$_path/$id');

    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = jsonBody['message']?.toString() ?? 'Failed to load custom field';
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
    debugPrint('API REQUEST: PATCH $_path/$id');
    final response = await _dio.patch('$_path/$id', data: field.toUpdateJson());

    debugPrint('API RESPONSE: PATCH $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = jsonBody['message']?.toString() ?? 'Failed to update custom field';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return CustomFieldModel.fromJson(data);
  }

  // ─── DELETE ───────────────────────────────────────────────────────────────
  Future<void> delete(int id) async {
    debugPrint('API REQUEST: DELETE $_path/$id');
    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      final jsonBody = response.data as Map<String, dynamic>;
      final message = jsonBody['message']?.toString() ?? 'Failed to delete custom field';
      throw Exception(message);
    }
  }
  // ─── LOOKUPS ──────────────────────────────────────────────────────────────
  Future<List<LookupDataTypeModel>> getDatatypes() async {
    debugPrint('API REQUEST: GET $_path/lookup/datatype');
    final response = await _dio.get('$_path/lookup/datatype');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load datatypes');
    }

    final jsonBody = response.data as Map<String, dynamic>;
    final data = jsonBody['data'] as List<dynamic>? ?? <dynamic>[];
    return data.map((e) => LookupDataTypeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LookupValidationRuleModel>> getValidationRules(int fieldDataTypeId) async {
    debugPrint('API REQUEST: GET $_path/lookup/validation-rule?FieldDataTypeId=$fieldDataTypeId');
    final response = await _dio.get(
      '$_path/lookup/validation-rule',
      queryParameters: {'FieldDataTypeId': fieldDataTypeId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load validation rules');
    }

    final jsonBody = response.data as Map<String, dynamic>;
    final itemsJson = (jsonBody['data']?['items'] as List<dynamic>?) ?? <dynamic>[];
    return itemsJson.map((e) => LookupValidationRuleModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
