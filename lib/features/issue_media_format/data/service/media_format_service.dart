import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_model.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_filter.dart';

class MediaFormatService {
  static const String _path = '/issue-media-format';

  Future<(IssueMediaFormatModel, String)> createMediaFormat(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"issueMediaFormat":"$name"}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'issueMediaFormat': name}),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (createMediaFormat): status=${response.statusCode}, body=${response.body}',
      );
      final errorMessage =
          jsonBody['message']?.toString() ??
          'Failed to create issue media format';
      throw Exception(errorMessage);
    }
    final message =
        jsonBody['message']?.toString() ??
        'Issue media format created successfully';
    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueMediaFormatModel.fromJson(data), message);
  }

  Future<PaginatedResponse<IssueMediaFormatModel>> getAll(
    IssueMediaFormatFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$_path',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET issue media formats): ${response.body}');
      final message =
          jsonBody['message']?.toString() ??
          'Failed to load issue media formats';
      throw Exception(message);
    }
    debugPrint('API MESSAGE (GET issue media formats): ${jsonBody['message']}');

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => IssueMediaFormatModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<IssueMediaFormatModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<IssueMediaFormatModel> getById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $url -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR BODY (GET issue media format by id): ${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to load issue media format';
      throw Exception(message);
    }
    debugPrint(
      'API MESSAGE (GET issue media format by id): ${jsonBody['message']}',
    );

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaFormatModel.fromJson(data);
  }

  Future<IssueMediaFormatModel> updateMediaFormat({
    required int id,
    String? issueMediaFormat,
    bool? active,
  }) async {
    if (issueMediaFormat == null && active == null) {
      throw Exception('Nothing to update');
    }

    final Map<String, dynamic> body = {};

    if (issueMediaFormat != null) {
      body['issueMediaFormat'] = issueMediaFormat;
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
        'API ERROR (updateMediaFormat): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to update issue media format';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaFormatModel.fromJson(data);
  }

  Future<IssueMediaFormatModel> deleteMediaFormat(int id) async {
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
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode == 200 || response.statusCode == 201
            ? 'Issue media format deleted successfully'
            : 'Failed to delete issue media format');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (deleteMediaFormat): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaFormatModel.fromJson(data);
  }

  // Future<IssueMediaFormatModel> recoverMediaFormat(int id) async {}

  Future<IssueMediaFormatModel> recoverMediaFormat(int id) async {
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
        'API ERROR (recoverMediaFormat): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to recover issue media format';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaFormatModel.fromJson(data);
  }
}
