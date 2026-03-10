import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_charactertype_model.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_character_type_filter.dart';

class CharacterTypeService {
  static const String _path = '/issue-character-type';

  /// Create a new issue character type
  ///
  /// Request body:
  ///   { "issueCharacterType": "string" }
  Future<(IssueCharacterTypeModel, String)> createCharacterType(
    String name,
  ) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"issueCharacterType":"$name"}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'issueCharacterType': name}),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode == 200 || response.statusCode == 201
            ? 'Issue character type created successfully'
            : 'Failed to create issue character type');

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR (createCharacterType): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueCharacterTypeModel.fromJson(data), message);
  }

  /// Get all issue character types (paged)
  ///
  /// Uses the endpoint:
  ///   GET https://voicefirst.admin.notetech.com/api/issue-character-type
  /// and maps the response `data.items` into IssueCharacterTypeModel.
  Future<PaginatedResponse<IssueCharacterTypeModel>> getAll(
    IssueCharacterTypeFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}$_path',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $uri');

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $uri -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR BODY (GET issue character types): ${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to load issue character types';
      throw Exception(message);
    }
    debugPrint(
      'API MESSAGE (GET issue character types): ${jsonBody['message']}',
    );

    final data = jsonBody['data'] as Map<String, dynamic>;
    final itemsJson = data['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => IssueCharacterTypeModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<IssueCharacterTypeModel>(
      items: items,
      totalCount: data['totalCount'] as int? ?? items.length,
      pageNumber: data['pageNumber'] as int? ?? filter.pageNumber,
      pageSize: data['pageSize'] as int? ?? filter.pageSize,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  /// Get a single issue character type by ID
  ///
  /// Endpoint:
  ///   GET https://voicefirst.admin.notetech.com/api/issue-character-type/{id}
  Future<IssueCharacterTypeModel> getById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}$_path/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint('API RESPONSE: GET $url -> ${response.statusCode}');

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200 && response.statusCode != 201) {
      debugPrint(
        'API ERROR BODY (GET issue character type by id): ${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to load issue character type';
      throw Exception(message);
    }
    debugPrint(
      'API MESSAGE (GET issue character type by id): ${jsonBody['message']}',
    );

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueCharacterTypeModel.fromJson(data);
  }

  /// Update an issue character type
  ///
  /// Request body supports partial updates, e.g.:
  ///   { "issueCharacterType": "string", "active": true }
  /// Only non-null fields are sent so we pass only changed data.
  Future<IssueCharacterTypeModel> updateCharacterType({
    required int id,
    String? issueCharacterType,
    bool? active,
  }) async {
    if (issueCharacterType == null && active == null) {
      throw Exception('Nothing to update');
    }

    final Map<String, dynamic> body = {};

    if (issueCharacterType != null) {
      body['issueCharacterType'] = issueCharacterType;
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
        'API ERROR (updateCharacterType): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to update issue character type';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueCharacterTypeModel.fromJson(data);
  }

  /// Soft delete an issue character type
  Future<IssueCharacterTypeModel> deleteCharacterType(int id) async {
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
        'API ERROR (deleteCharacterType): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to delete issue character type';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueCharacterTypeModel.fromJson(data);
  }

  /// Recover a previously deleted issue character type
  Future<IssueCharacterTypeModel> recoverCharacterType(int id) async {
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
        'API ERROR (recoverCharacterType): status=${response.statusCode}, body=${response.body}',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to recover issue character type';
      throw Exception(message);
    }
    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueCharacterTypeModel.fromJson(data);
  }
}
