import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_model.dart';
import 'package:voice_first_admin/features/issue_status/data/models/issue_status_filter.dart';

class IssueStatusService {
  static const String _path = '/issue-status';

  Future<(IssueStatusModel, String)> createStatus(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"issueStatus":"$name"}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'issueStatus': name}),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode == 200 || response.statusCode == 201
            ? 'Issue status created successfully'
            : 'Failed to create issue status');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (createStatus): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueStatusModel.fromJson(data), message);
  }

  Future<PaginatedResponse<IssueStatusModel>> getAll(
    IssueStatusFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$_path',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET issue statuses): ${response.body}');
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load issue statuses';
      throw Exception(message);
    }
    debugPrint('API MESSAGE (GET issue statuses): ${jsonBody['message']}');

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
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $url -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint('API ERROR BODY (GET issue status by id): ${response.body}');
      final message =
          jsonBody['message']?.toString() ?? 'Failed to load issue status';
      throw Exception(message);
    }
    debugPrint('API MESSAGE (GET issue status by id): ${jsonBody['message']}');

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
        'API ERROR (updateStatus): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ?? 'Failed to update issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }

  Future<IssueStatusModel> deleteStatus(int id) async {
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
        'API ERROR (deleteStatus): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ?? 'Failed to delete issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }

  Future<IssueStatusModel> recoverStatus(int id) async {
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
        'API ERROR (recoverStatus): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ?? 'Failed to recover issue status';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueStatusModel.fromJson(data);
  }
}
