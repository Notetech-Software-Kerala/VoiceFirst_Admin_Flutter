import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/program_actions/data/models/paginated_response.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_model.dart';
import 'package:voice_first_admin/features/issue_media_format/data/models/issue_media_format_filter.dart';

class MediaFormatRepository {
  final Dio _dio;
  MediaFormatRepository(this._dio);

  static const String _path = '/issue-media-format';

  Future<(IssueMediaFormatModel, String)> createMediaFormat(String name) async {
    debugPrint('API REQUEST: POST $_path');
    debugPrint('Request Body: {"issueMediaFormat":"$name"}');

    final response = await _dio.post(_path, data: {'issueMediaFormat': name});

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (createMediaFormat): status=${response.statusCode}, body=$jsonBody',
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
      debugPrint('API ERROR BODY (GET issue media formats): $jsonBody');
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
    debugPrint('API REQUEST: GET $_path/$id');

    final response = await _dio.get('$_path/$id');

    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint('API ERROR BODY (GET issue media format by id): $jsonBody');
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
    if (issueMediaFormat != null) body['issueMediaFormat'] = issueMediaFormat;
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
        'API ERROR (updateMediaFormat): status=${response.statusCode}, body=$jsonBody',
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
    debugPrint('API REQUEST: DELETE $_path/$id');

    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;
    final message =
        jsonBody['message']?.toString() ??
        'Failed to delete issue media format';

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      debugPrint(
        'API ERROR (deleteMediaFormat): status=${response.statusCode}, body=$jsonBody',
      );
      throw Exception(message);
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    return IssueMediaFormatModel.fromJson(data);
  }

  Future<IssueMediaFormatModel> recoverMediaFormat(int id) async {
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
        'API ERROR (recoverMediaFormat): status=${response.statusCode}, body=$jsonBody',
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

final issueMediaFormatRepositoryProvider = Provider<MediaFormatRepository>((
  ref,
) {
  return MediaFormatRepository(ref.read(dioClientProvider));
});
