import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpints.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_filter.dart';
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

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
  Future<BusinessActivity> createActivity(String name) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activity');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"activityName":"$name"}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'activityName': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return BusinessActivity.fromJson(json['data']);
    } else {
      throw Exception('Failed to create activity');
    }
  }

  Future<PaginatedResponse<BusinessActivity>> getAllActivities(
    BusinessActivityFilter filter,
  ) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/business-activity',
    ).replace(queryParameters: filter.toQueryParams());

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load activities');
    }

    final json = jsonDecode(response.body);

    return PaginatedResponse.fromJson(
      json['data'],
      (e) => BusinessActivity.fromJson(e),
    );
  }

  Future<BusinessActivity> getActivityById(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activity/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(url, headers: ApiEndpoints.defaultHeaders);

    if (response.statusCode != 200) {
      throw Exception('Failed to load activity: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> updateActivity({
    required int id,
    String? activityName,
    bool? active,
  }) async {
    if (activityName == null && active == null) {
      throw Exception('Nothing to update');
    }

    final Map<String, dynamic> body = {};

    if (activityName != null) {
      body['activityName'] = activityName;
    }
    if (active != null) {
      body['active'] = active;
    }
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activity/$id');

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update activity');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<void> toggleStatus(int id, bool active) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/business-activity/$id/status',
    );

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: ${jsonEncode({'active': active})}');

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle status: ${response.statusCode}');
    }
  }

  Future<BusinessActivity> recoverActivity(int id) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/business-activity/recover/$id',
    );

    final response = await http.patch(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to recover activity');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> deleteActivity(int id) async {
    final url = Uri.parse('${ApiEndpoints.baseUrl}/business-activity/$id');

    final response = await http.delete(
      url,
      headers: ApiEndpoints.defaultHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<void> bulkDelete(List<int> ids) async {
    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}/business-activity/bulk-delete',
    );

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await http.post(
      url,
      headers: ApiEndpoints.defaultHeaders,
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to bulk delete activities: ${response.statusCode}',
      );
    }
  }
}
