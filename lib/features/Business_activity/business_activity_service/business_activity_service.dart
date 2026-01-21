import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/features/Business_activity/models/business_activity_model.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      items: (json['items'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

class BusinessActivityService {
  static const String _baseUrl = 'http://192.168.0.202:8010/api';

  Future<BusinessActivity> createActivity(String name) async {
    final url = Uri.parse('$_baseUrl/business-activity');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"name":"$name"}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BusinessActivity.fromJson(json['data']);
    } else {
      throw Exception('Failed to create activity');
    }
  }

  Future<PaginatedResponse<BusinessActivity>> getAllActivities({
    int pageNumber = 1,
    int pageSize = 10,
    String? searchTerm,
    bool? isActive,
    String sortBy = 'name',
    bool sortDescending = false,
  }) async {
    final queryParams = <String, String>{
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'sortBy': sortBy,
      'sortDescending': sortDescending.toString(),
    };

    if (searchTerm != null && searchTerm.isNotEmpty) {
      queryParams['searchTerm'] = searchTerm;
    }

    if (isActive != null) {
      queryParams['isActive'] = isActive.toString();
    }

    final url = Uri.parse(
      '$_baseUrl/business-activity',
    ).replace(queryParameters: queryParams);

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load activities: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    final data = json['data'] as Map<String, dynamic>;

    return PaginatedResponse.fromJson(
      data,
      (json) => BusinessActivity.fromJson(json),
    );
  }

  Future<BusinessActivity> getActivityById(int id) async {
    final url = Uri.parse('$_baseUrl/business-activity/$id');

    debugPrint('API REQUEST: GET $url');

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load activity: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<BusinessActivity> updateActivity(int id, String name) async {
    final url = Uri.parse('$_baseUrl/business-activity/$id');

    debugPrint('API REQUEST: PUT $url');
    debugPrint('Request Body: {"name":"$name"}');

    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update activity: ${response.statusCode}');
    }

    final json = jsonDecode(response.body);
    return BusinessActivity.fromJson(json['data']);
  }

  Future<void> toggleStatus(int id, bool active) async {
    final url = Uri.parse('$_baseUrl/business-activity/$id/status');

    debugPrint('API REQUEST: PATCH $url');
    debugPrint('Request Body: {"active":$active}');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'active': active}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to toggle status: ${response.statusCode}');
    }
  }

  Future<void> deleteActivity(int id) async {
    final url = Uri.parse('$_baseUrl/business-activity/$id');

    debugPrint('API REQUEST: DELETE $url');

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete activity: ${response.statusCode}');
    }
  }

  Future<void> bulkDelete(List<int> ids) async {
    final url = Uri.parse('$_baseUrl/business-activity/bulk-delete');

    debugPrint('API REQUEST: POST $url');
    debugPrint('Request Body: {"ids":$ids}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ids': ids}),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to bulk delete activities: ${response.statusCode}',
      );
    }
  }
}


// import '../../../core/services/api_client.dart';
// import '../../../core/models/paged_filter.dart';
// import '../../../core/models/paged_result.dart';
// import '../domain/business_activity.dart';

// class BusinessActivityService {
//   final _dio = ApiClient().dio;

  // Future<PagedResult<BusinessActivity>> getAll(
  //   PagedFilter filter,
  // ) async {
  //   final response = await _dio.get(
  //     '/business-activity',
  //     queryParameters: filter.toQuery(),
  //   );

  //   return PagedResult.fromJson(
  //     response.data['data'],
  //     (json) => BusinessActivity.fromJson(json),
  //   );
  // }

//   Future<void> toggleStatus(int id, bool active) async {
//     await _dio.patch(
//       '/business-activity/$id/status',
//       data: {'active': active},
//     );
//   }

//   Future<BusinessActivity> create(String name) async {
//     final response = await _dio.post(
//       '/business-activity',
//       data: {'name': name},
//     );

//     return BusinessActivity.fromJson(response.data['data']);
//   }

//   Future<void> delete(int id) async {
//     await _dio.delete('/business-activity/$id');
//   }
// }
