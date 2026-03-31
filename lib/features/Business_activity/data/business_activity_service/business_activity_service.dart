import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/business_activity_filter.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/business_activity_model.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/custom_field_lookup_model.dart';
import 'package:voice_first_admin/features/Business_activity/data/models/update_activity_request.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['pageNumber'], // API compatible
      pageSize: json['pageSize'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
    );
  }
}

class BusinessActivityService {
  final Dio _dio;
  BusinessActivityService(this._dio);

  static const String _path = '/activity';
  Future<BusinessActivity> createActivity(
    String name, {
    List<int>? customFieldIds,
  }) async {
    final body = {
      "activityName": name,
      if (customFieldIds != null && customFieldIds.isNotEmpty)
        "addCustomFieldIds": customFieldIds,
    };

    debugPrint('API REQUEST: POST $_path');
    debugPrint('Request Body: $body');

    final response = await _dio.post(_path, data: body);

    debugPrint('API RESPONSE: POST $_path -> ${response.statusCode}');

    final json = response.data as Map<String, dynamic>;

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return BusinessActivity.fromJson(json['data']);
    }

    final msg = json['message']?.toString() ?? 'Failed to create activity';
    throw Exception(msg);
  }

  Future<PaginatedResponse<BusinessActivity>> getAllActivities(
    BusinessActivityFilter filter,
  ) async {
    debugPrint('API REQUEST: GET $_path');

    final response = await _dio.get(
      _path,
      queryParameters: filter.toQueryParams(),
    );

    debugPrint('API RESPONSE: GET $_path -> ${response.statusCode}');

    final json = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          json['message']?.toString() ?? 'Failed to load activities';
      throw Exception(message);
    }

    return PaginatedResponse.fromJson(
      json['data'],
      (e) => BusinessActivity.fromJson(e),
    );
  }

  Future<BusinessActivity> getActivityById(int id) async {
    debugPrint('API REQUEST: GET $_path/$id');

    final response = await _dio.get('$_path/$id');

    debugPrint('API RESPONSE: GET $_path/$id -> ${response.statusCode}');

    final json = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message = json['message']?.toString() ?? 'Failed to load activity';
      throw Exception(message);
    }

    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> updateActivity(
    int id,
    UpdateActivityRequest request,
  ) async {
    final body = request.toJson();

    debugPrint('API REQUEST: PATCH $_path/$id');
    debugPrint('Request Body: $body');

    final response = await _dio.patch('$_path/$id', data: body);

    debugPrint('API RESPONSE: PATCH $_path/$id -> ${response.statusCode}');

    final jsonBody = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          jsonBody['message']?.toString() ?? 'Failed to update activity';
      throw Exception(message);
    }

    debugPrint('API MESSAGE (update activity): ${jsonBody['message']}');

    return BusinessActivity.fromJson(jsonBody['data']);
  }

  Future<void> toggleStatus(int id, bool active) async {
    debugPrint('API REQUEST: PATCH $_path/$id/status');
    debugPrint('Request Body: ${{'"active"': active}}');

    final response = await _dio.patch(
      '$_path/$id/status',
      data: {'active': active},
    );

    debugPrint(
      'API RESPONSE: PATCH $_path/$id/status -> ${response.statusCode}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final json = response.data as Map<String, dynamic>?;
      debugPrint(
        'API ERROR (toggleStatus): status=${response.statusCode}, body=$json',
      );
      throw Exception('Failed to toggle status: ${response.statusCode}');
    }
  }

  Future<BusinessActivity> recoverActivity(int id) async {
    debugPrint('API REQUEST: PATCH $_path/recover/$id');

    final response = await _dio.patch('$_path/recover/$id');

    debugPrint(
      'API RESPONSE: PATCH $_path/recover/$id -> ${response.statusCode}',
    );

    final json = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          json['message']?.toString() ?? 'Failed to recover activity';
      throw Exception(message);
    }

    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> deleteActivity(int id) async {
    debugPrint('API REQUEST: DELETE $_path/$id');

    final response = await _dio.delete('$_path/$id');

    debugPrint('API RESPONSE: DELETE $_path/$id -> ${response.statusCode}');

    final json = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final message =
          json['message']?.toString() ?? 'Failed to delete activity';
      throw Exception(message);
    }

    return BusinessActivity.fromJson(json['data']);
  }

  Future<void> bulkDelete(List<int> ids) async {
    debugPrint('API REQUEST: POST $_path/bulk-delete');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await _dio.post('$_path/bulk-delete', data: {'ids': ids});

    debugPrint(
      'API RESPONSE: POST $_path/bulk-delete -> ${response.statusCode}',
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final json = response.data as Map<String, dynamic>?;
      debugPrint(
        'API ERROR (bulkDelete): status=${response.statusCode}, body=$json',
      );
      throw Exception(
        'Failed to bulk delete activities: ${response.statusCode}',
      );
    }
  }

  Future<List<CustomFieldLookup>> getCustomFieldLookup() async {
    debugPrint('API REQUEST: GET /user-custom-field/lookup');

    final response = await _dio.get('/user-custom-field/lookup');

    debugPrint(
      'API RESPONSE: GET /user-custom-field/lookup -> ${response.statusCode}',
    );

    final json = response.data as Map<String, dynamic>;

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to load custom fields');
    }

    final items = (json['data']?['items'] as List<dynamic>?) ?? <dynamic>[];

    return items
        .map((e) => CustomFieldLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
