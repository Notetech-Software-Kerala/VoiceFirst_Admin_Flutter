import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_model.dart';
import 'package:voice_first_admin/features/issue_type/data/models/issue_type_filter.dart';

class IssueTypeService {
  static const String _path = '/issue-type';

  Future<(IssueTypeModel, String)> createType({
    required String name,
    String? description,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');
    final body = <String, dynamic>{'issueType': name};
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    debugPrint('API RESPONSE: POST $url -> ${response.statusCode} ${response.body}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode == 200 || response.statusCode == 201
            ? 'Issue type created successfully'
            : 'Failed to create issue type');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR (createType): status=${response.statusCode}, body=${response.body}');
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueTypeModel.fromJson(data), message);
  }

  Future<PaginatedResponse<IssueTypeModel>> getAll(IssueTypeFilter filter) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}$_path')
        .replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET issue types): ${response.body}');
      final message = jsonBody['message']?.toString() ?? 'Failed to load issue types';
      throw Exception(message);
    }
    debugPrint('API MESSAGE (GET issue types): ${jsonBody['message']}');

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => IssueTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<IssueTypeModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<IssueTypeModel> getById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $url -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET issue type by id): ${response.body}');
      final message = jsonBody['message']?.toString() ?? 'Failed to load issue type';
      throw Exception(message);
    }
    debugPrint('API MESSAGE (GET issue type by id): ${jsonBody['message']}');

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

    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    debugPrint('API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR (updateType): status=${response.statusCode}, body=${response.body}');
      final message = jsonBody['message']?.toString() ?? 'Failed to update issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }

  Future<IssueTypeModel> deleteType(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: DELETE $url -> ${response.statusCode} ${response.body}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR (deleteType): status=${response.statusCode}, body=${response.body}');
      final message = jsonBody['message']?.toString() ?? 'Failed to delete issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }

  Future<IssueTypeModel> recoverType(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/recover/$id');

    debugPrint('API REQUEST: PATCH $url');

    final response = await http.patch(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR (recoverType): status=${response.statusCode}, body=${response.body}');
      final message = jsonBody['message']?.toString() ?? 'Failed to recover issue type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueTypeModel.fromJson(data);
  }
}
