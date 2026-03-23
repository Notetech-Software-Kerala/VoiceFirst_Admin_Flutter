import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';
import 'package:voice_first_admin/features/Business_activity/models/custom_field_lookup_model.dart';
import 'package:voice_first_admin/features/Business_activity/models/update_activity_request.dart';

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
  Future<BusinessActivity> createActivity(
    String name, {
    List<int>? customFieldIds,
  }) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity');

    final body = {
      "activityName": name,
      if (customFieldIds != null && customFieldIds.isNotEmpty)
        "addCustomFieldIds": customFieldIds,
    };

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return BusinessActivity.fromJson(json['data']);
    }

    throw Exception('Failed to create activity');
  }

  Future<PaginatedResponse<BusinessActivity>> getAllActivities(
    BusinessActivityFilter filter,
  ) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/activity',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint(
      'API RESPONSE: GET $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      debugPrint(
        'API ERROR (getAllActivities): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to load activities');
    }

    final json = jsonDecode(response.body);

    return PaginatedResponse.fromJson(
      json['data'],
      (e) => BusinessActivity.fromJson(e),
    );
  }

  Future<BusinessActivity> getActivityById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint(
      'API RESPONSE: GET $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      debugPrint(
        'API ERROR (getActivityById): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to load activity: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> updateActivity(
    int id,
    UpdateActivityRequest request,
  ) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity/$id');

    final body = request.toJson();

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    debugPrint('API RESPONSE: PATCH $url -> ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('API ERROR BODY (update activity): ${response.body}');
      throw Exception('Failed to update activity: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);

    debugPrint('API MESSAGE (update activity): ${jsonBody['message']}');

    return BusinessActivity.fromJson(jsonBody['data']);
  }

  Future<void> toggleStatus(int id, bool active) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity/$id/status');

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode({'active': active})}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'active': active}),
    );

    debugPrint(
      'API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      debugPrint(
        'API ERROR (toggleStatus): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to toggle status: ${response.statusCode}');
    }
  }

  Future<BusinessActivity> recoverActivity(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity/recover/$id');

    debugPrint('API REQUEST: PATCH $url');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint(
      'API RESPONSE: PATCH $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      debugPrint(
        'API ERROR (recoverActivity): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to recover activity');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> deleteActivity(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    debugPrint(
      'API RESPONSE: DELETE $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      debugPrint(
        'API ERROR (deleteActivity): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception('Failed to delete activity');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<void> bulkDelete(List<int> ids) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/activity/bulk-delete');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'ids': ids}),
    );

    debugPrint(
      'API RESPONSE: POST $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      debugPrint(
        'API ERROR (bulkDelete): status=${response.statusCode}, body=${response.body}',
      );
      throw Exception(
        'Failed to bulk delete activities: ${response.statusCode}',
      );
    }
  }

  Future<List<CustomFieldLookup>> getCustomFieldLookup() async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/user-custom-field/lookup');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    debugPrint(
      'API RESPONSE: GET $url -> ${response.statusCode} ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to load custom fields");
    }

    final json = jsonDecode(response.body);

    final items = json['data']['items'] as List;

    return items.map((e) => CustomFieldLookup.fromJson(e)).toList();
  }
}
