import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan_model.dart';

/// Generic paginated response for plan (matches BusinessActivityService)
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
      items: (json['items'] as List? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      currentPage: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class PlanService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  PlanService({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Future<PaginatedResponse<PlanModel>> getPlans({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/plan').replace(
      queryParameters: {
        'pageNumber': page.toString(),
        'pageSize': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'searchText': search,
      },
    );

    final response = await http.get(uri, headers: defaultHeaders);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load plans: \\${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    return PaginatedResponse<PlanModel>.fromJson(
      jsonBody['data'],
      (e) => PlanModel.fromJson(e),
    );
  }
}
