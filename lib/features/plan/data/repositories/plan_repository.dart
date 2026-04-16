import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import 'package:voice_first_admin/features/plan/data/models/plan_model.dart';
import 'package:voice_first_admin/features/plan/data/models/program_action_link_lookup.dart';


/// PAGINATED RESPONSE

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

final planRepositoryProvider = Provider<PlanRepository>((ref) {
  return PlanRepository(ref.read(dioClientProvider));
});

////////////////////////////////////////////////////////////
/// SERVICE
////////////////////////////////////////////////////////////

class PlanRepository {
  final Dio _dio;

  PlanRepository(this._dio);

  ////////////////////////////////////////////////////////////
  /// GET ALL
  ////////////////////////////////////////////////////////////

  Future<PaginatedResponse<Plan>> getPlans({
    Map<String, String>? queryParams,
  }) async {
    final response = await _dio.get('/plan', queryParameters: queryParams);

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to load plans: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;

    return PaginatedResponse<Plan>.fromJson(
      jsonBody['data'],
      (e) => Plan.fromJson(e),
    );
  }

  ////////////////////////////////////////////////////////////
  /// GET BY ID
  ////////////////////////////////////////////////////////////

  Future<Plan> getPlanById(int id) async {
    final response = await _dio.get('/plan/$id');

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to load plan detail: ${response.statusCode}');
    }

    final jsonBody = response.data as Map<String, dynamic>;

    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// CREATE
  ////////////////////////////////////////////////////////////

  Future<Plan> createPlan({
    required String planName,
    required List<int> actionIds,
  }) async {
    debugPrint('[CREATE PLAN] POST /plan');
    debugPrint(
      '[CREATE PLAN] BODY: ${jsonEncode({"planName": planName, "programActionLinkIds": actionIds})}',
    );

    final response = await _dio.post(
      '/plan',
      data: {"planName": planName, "programActionLinkIds": actionIds},
    );

    debugPrint('[CREATE PLAN] STATUS: ${response.statusCode}');
    debugPrint('[CREATE PLAN] RESPONSE BODY: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to create plan: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// DELETE
  ////////////////////////////////////////////////////////////

  Future<Plan> deletePlan(int id) async {
    debugPrint('[DELETE PLAN] DELETE /plan/$id');
    final response = await _dio.delete('/plan/$id');
    debugPrint('[DELETE PLAN] STATUS: ${response.statusCode}');
    debugPrint('[DELETE PLAN] BODY: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to delete plan: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// RECOVER
  ////////////////////////////////////////////////////////////

  Future<Plan> recoverPlan(int id) async {
    debugPrint('[RECOVER PLAN] PATCH /plan/recover/$id');
    final response = await _dio.patch('/plan/recover/$id');
    debugPrint('[RECOVER PLAN] STATUS: ${response.statusCode}');
    debugPrint('[RECOVER PLAN] BODY: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception(
        'Failed to recover plan: ${response.statusCode} ${response.data}',
      );
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// PROGRAM ACTION LOOKUP
  ////////////////////////////////////////////////////////////

  Future<PaginatedResponse<ProgramActionLinkProgram>>
  getProgramActionLinkLookupPaginated({
    required int page,
    required int pageSize,
    String? search,
  }) async {
    debugPrint('[PROGRAM ACTION PAGINATED] GET /program/for-plan');
    final response = await _dio.get(
      '/program/for-plan',
      queryParameters: {
        'PageNumber': page.toString(),
        'Limit': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'SearchText': search,
      },
    );

    debugPrint('[PROGRAM ACTION PAGINATED] STATUS: ${response.statusCode}');
    debugPrint('[PROGRAM ACTION PAGINATED] RESPONSE BODY: ${response.data}');

    if (response.statusCode == null || response.statusCode! < 200) {
      throw Exception('Failed to load program/action links');
    }

    final jsonBody = response.data as Map<String, dynamic>;

    final paginated = PaginatedResponse<ProgramActionLinkProgram>.fromJson(
      jsonBody['data'],
      (e) => ProgramActionLinkProgram.fromJson(e),
    );

    debugPrint(
      '[PROGRAM ACTION PAGINATED] ITEMS LOADED: ${paginated.items.length}',
    );
    debugPrint(
      '[PROGRAM ACTION PAGINATED] PAGE: ${paginated.currentPage} / ${paginated.totalPages}, TOTAL COUNT: ${paginated.totalCount}',
    );

    return paginated;
  }
}
