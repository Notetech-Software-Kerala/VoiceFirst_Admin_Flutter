import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/program_actions/data/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_charactertype_model.dart';
import 'package:voice_first_admin/features/issue_character_type/data/models/issue_character_type_filter.dart';

class CharacterTypeRepository {
  final Dio _dio;
  CharacterTypeRepository(this._dio);

  static const String _path = '/issue-character-type';

  Future<(IssueCharacterTypeModel, String)> createCharacterType(
    String name,
  ) async {
    debugPrint('API REQUEST: POST $_path');
    debugPrint('Request Body: {"issueCharacterType":"$name"}');

    final response = await _dio.post(_path, data: {'issueCharacterType': name});

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode != null &&
                response.statusCode! >= 200 &&
                response.statusCode! < 300
            ? 'Issue character type created successfully'
            : 'Failed to create issue character type');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (createCharacterType): status=${response.statusCode}, body=$jsonBody',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueCharacterTypeModel.fromJson(data), message);
  }

  Future<PaginatedResponse<IssueCharacterTypeModel>> getAll(
    IssueCharacterTypeFilter filter,
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
      debugPrint('API ERROR BODY (GET issue character types): $jsonBody');
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

  Future<IssueCharacterTypeModel> getById(int id) async {
    debugPrint('API REQUEST: GET $_path/$id');

    final response = await _dio.get('$_path/$id');

    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (GET issue character type by id): $jsonBody');
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
    if (active != null) body['active'] = active;

    debugPrint('API REQUEST: PATCH $_path/$id');
    debugPrint('Request Body: $body');

    final response = await _dio.patch('$_path/$id', data: body);

    debugPrint('API RESPONSE: PATCH $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (updateCharacterType): status=${response.statusCode}, body=$jsonBody',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to update issue character type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueCharacterTypeModel.fromJson(data);
  }

  Future<IssueCharacterTypeModel> deleteCharacterType(int id) async {
    debugPrint('API REQUEST: DELETE $_path/$id');

    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (deleteCharacterType): status=${response.statusCode}, body=$jsonBody',
      );
      final message =
          jsonBody['message']?.toString() ??
          'Failed to delete issue character type';
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueCharacterTypeModel.fromJson(data);
  }

  Future<IssueCharacterTypeModel> recoverCharacterType(int id) async {
    debugPrint('API REQUEST: PATCH $_path/recover/$id');

    final response = await _dio.patch('$_path/recover/$id');

    debugPrint(
      'API RESPONSE: PATCH $_path/recover/$id -> ${response.statusCode}',
    );

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (recoverCharacterType): status=${response.statusCode}, body=$jsonBody',
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

final characterTypeRepositoryProvider = Provider<CharacterTypeRepository>((
  ref,
) {
  return CharacterTypeRepository(ref.read(dioClientProvider));
});
