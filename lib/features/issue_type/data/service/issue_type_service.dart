import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_filter.dart';

class IssueTypeService {
  final Dio _dio;
  IssueTypeService(this._dio);

  static const String _path = '/issue-type';

  Future<(IssueTypeModel, String)> createType({
    required String name,
    String? description,
  }) async {
    final body = <String, dynamic>{'issueType': name};
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }

    debugPrint('API REQUEST: POST $_path');
    
    final response = await _dio.post(_path, data: body);
    
    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;
    final message = jsonBody['message']?.toString() ?? 'Issue type created successfully';

    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = jsonBody['data'] as Map<String, dynamic>;
      return (IssueTypeModel.fromJson(data), message);
    } else {
      throw Exception(message);
    }
  }

  Future<PaginatedResponse<IssueTypeModel>> getAll(IssueTypeFilter filter) async {
    debugPrint('API REQUEST: GET $_path');
    
    final response = await _dio.get(_path, queryParameters: filter.toQueryParams());
    
    debugPrint('API RESPONSE: GET $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      final message = jsonBody['message']?.toString() ?? 'Failed to load issue types';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson.map((e) => IssueTypeModel.fromJson(e as Map<String, dynamic>)).toList();

    return PaginatedResponse<IssueTypeModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<IssueTypeModel> getById(int id) async {
    debugPrint('API REQUEST: GET $_path/$id');
    
    final response = await _dio.get('$_path/$id');
    
    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      final message = jsonBody['message']?.toString() ?? 'Failed to load issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }

  Future<IssueTypeModel> updateType({
    required int id,
    String? issueType,
    String? description,
    bool? active,
  }) async {
    if (issueType == null && description == null && active == null) {
      throw Exception('Nothing to update');
    }

    final Map<String, dynamic> body = {};
    if (issueType != null) body['issueType'] = issueType;
    if (description != null) body['description'] = description;
    if (active != null) body['active'] = active;

    debugPrint('API REQUEST: PATCH $_path/$id');
    
    final response = await _dio.patch('$_path/$id', data: body);
    
    debugPrint('API RESPONSE: PATCH $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      final message = jsonBody['message']?.toString() ?? 'Failed to update issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }

  Future<IssueTypeModel> deleteType(int id) async {
    debugPrint('API REQUEST: DELETE $_path/$id');
    
    final response = await _dio.delete('$_path/$id');
    
    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      final message = jsonBody['message']?.toString() ?? 'Failed to delete issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }

  Future<IssueTypeModel> recoverType(int id) async {
    debugPrint('API REQUEST: PATCH $_path/recover/$id');
    
    final response = await _dio.patch('$_path/recover/$id');
    
    debugPrint('API RESPONSE: PATCH $_path/recover/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
      final message = jsonBody['message']?.toString() ?? 'Failed to recover issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }
}
