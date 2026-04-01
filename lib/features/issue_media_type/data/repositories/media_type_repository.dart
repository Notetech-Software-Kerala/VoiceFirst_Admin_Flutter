import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/program_action/data/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_model.dart';
import 'package:voice_first_admin/features/issue_media_type/data/models/issue_media_type_filter.dart';

class MediaTypeRepository {
  final Dio _dio;
  static const String _path = '/issue-media-type';

  MediaTypeRepository(this._dio);

  Future<(IssueMediaTypeModel, String)> createMediaType(String name) async {
    debugPrint('API REQUEST: POST $_path');
    debugPrint('Request Body: {"issueMediaType":"$name"}');

    final response = await _dio.post(_path, data: {'issueMediaType': name});

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        (response.statusCode != null &&
                response.statusCode! >= 200 &&
                response.statusCode! < 300
            ? 'Issue media type created successfully'
            : 'Failed to create issue media type');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (createMediaType): status=${response.statusCode}, body=$jsonBody',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return (IssueMediaTypeModel.fromJson(data), message);
  }

  Future<PaginatedResponse<IssueMediaTypeModel>> getAll(
    IssueMediaTypeFilter filter,
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
      debugPrint('API ERROR BODY (GET issue media types): $jsonBody');
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
    debugPrint('API REQUEST: GET $_path/$id');

    final response = await _dio.get('$_path/$id');

    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (GET issue media type by id): $jsonBody');
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

    if (issueMediaType != null) body['issueMediaType'] = issueMediaType;
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
        'API ERROR (updateMediaType): status=${response.statusCode}, body=$jsonBody',
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
    debugPrint('API REQUEST: DELETE $_path/$id');

    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (deleteMediaType): status=${response.statusCode}, body=$jsonBody',
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
        'API ERROR (recoverMediaType): status=${response.statusCode}, body=$jsonBody',
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

final issueMediaTypeRepositoryProvider = Provider<MediaTypeRepository>((ref) {
  return MediaTypeRepository(ref.read(dioClientProvider));
});
