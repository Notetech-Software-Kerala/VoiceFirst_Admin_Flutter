import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_filter.dart';

class MediaTypeService {
  static const String _path = '/issue-media-type';

  Future<(IssueMediaTypeModel, String)> createMediaType(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"issueMediaType":"$name"}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'issueMediaType': name}),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode == 200 || response.statusCode == 201
            ? 'Issue media type created successfully'
            : 'Failed to create issue media type');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (createMediaType): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueMediaTypeModel.fromJson(data), message);
  }

  Future<PaginatedResponse<IssueMediaTypeModel>> getAll(
    IssueMediaTypeFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$_path',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET issue media types): ${response.body}');
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load issue media types';
      throw Exception(message);
    }
    debugPrint('API MESSAGE (GET issue media types): ${jsonBody['message']}');

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => IssueMediaTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<IssueMediaTypeModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<IssueMediaTypeModel> getById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $url -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR BODY (GET issue media type by id): ${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load issue media type';
      throw Exception(message);
    }
    debugPrint(
      'API MESSAGE (GET issue media type by id): ${jsonBody['message']}',
    );

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaTypeModel.fromJson(data);
  }

  Future<IssueMediaTypeModel> updateMediaType({
    required int id,
    String? issueMediaType,
    bool? active,
  }) async {
    if (issueMediaType == null && active == null) {
      throw Exception('Nothing to update');
    }

    final Map<String, dynamic> body = {};

    if (issueMediaType != null) {
      body['issueMediaType'] = issueMediaType;
    }
    if (active != null) {
      body['active'] = active;
    }

    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    debugPrint(
      'API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (updateMediaType): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to update issue media type';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaTypeModel.fromJson(data);
  }

  Future<IssueMediaTypeModel> deleteMediaType(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint(
      'API RESPONSE: DELETE $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (deleteMediaType): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to delete issue media type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaTypeModel.fromJson(data);
  }

  Future<IssueMediaTypeModel> recoverMediaType(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/recover/$id');

    debugPrint('API REQUEST: PATCH $url');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint(
      'API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (recoverMediaType): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to recover issue media type';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaTypeModel.fromJson(data);
  }
}
