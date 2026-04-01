import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:voice_first_admin/features/program_action/data/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_model.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_filter.dart';

class IssueStatusRepository {
  final Dio _dio;
  IssueStatusRepository(this._dio);

  static const String _path = '/issue-status';

  Future<(IssueStatusModel, String)> createStatus(String name) async {
    debugPrint('API REQUEST: POST $_path');

    final response = await _dio.post(_path, data: {'issueStatus': name});

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ?? 'Issue status created successfully';

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = jsonBody['data'] as Map<String, dynamic>;
      return (IssueStatusModel.fromJson(data), message);
    } else {
      throw Exception(message);
    }
  }

  Future<PaginatedResponse<IssueStatusModel>> getAll(
    IssueStatusFilter filter,
  ) async {
    debugPrint('API REQUEST: GET $_path');

    final response = await _dio.get(
      _path,
      queryParameters: filter.toQueryParams(),
    );

    debugPrint('API RESPONSE: GET $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load issue statuses';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => IssueStatusModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<IssueStatusModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<IssueStatusModel> getById(int id) async {
    debugPrint('API REQUEST: GET $_path/$id');

    final response = await _dio.get('$_path/$id');

    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }

  Future<IssueStatusModel> updateStatus({
    required int id,
    String? issueStatus,
    bool? active,
  }) async {
    if (issueStatus == null && active == null) {
      throw Exception('Nothing to update');
    }

    final Map<String, dynamic> body = {};
    if (issueStatus != null) body['issueStatus'] = issueStatus;
    if (active != null) body['active'] = active;

    debugPrint('API REQUEST: PATCH $_path/$id');

    final response = await _dio.patch('$_path/$id', data: body);

    debugPrint('API RESPONSE: PATCH $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to update issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }

  Future<IssueStatusModel> deleteStatus(int id) async {
    debugPrint('API REQUEST: DELETE $_path/$id');

    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to delete issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }

  Future<IssueStatusModel> recoverStatus(int id) async {
    debugPrint('API REQUEST: PATCH $_path/recover/$id');

    final response = await _dio.patch('$_path/recover/$id');

    debugPrint(
      'API RESPONSE: PATCH $_path/recover/$id -> ${response.statusCode}',
    );

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to recover issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }
}
