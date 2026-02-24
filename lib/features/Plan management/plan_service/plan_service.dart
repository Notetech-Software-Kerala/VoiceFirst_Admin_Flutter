import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/plan_model.dart';
import '../models/program_action_link_lookup.dart';

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

////////////////////////////////////////////////////////////
/// SERVICE
////////////////////////////////////////////////////////////

class PlanService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  PlanService({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  ////////////////////////////////////////////////////////////
  /// GET ALL
  ////////////////////////////////////////////////////////////

  Future<PaginatedResponse<Plan>> getPlans({
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
      throw Exception('Failed to load plans: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);

    return PaginatedResponse<Plan>.fromJson(
      jsonBody['data'],
      (e) => Plan.fromJson(e),
    );
  }

  ////////////////////////////////////////////////////////////
  /// GET BY ID
  ////////////////////////////////////////////////////////////

  Future<Plan> getPlanById(int id) async {
    final uri = Uri.parse('$baseUrl/plan/$id');

    final response = await http.get(uri, headers: defaultHeaders);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load plan detail: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);

    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// CREATE
  ////////////////////////////////////////////////////////////

  Future<Plan> createPlan({
    required String planName,
    required List<int> actionIds,
  }) async {
    final uri = Uri.parse('$baseUrl/plan');
    debugPrint('[CREATE PLAN] URI: $uri');
    debugPrint('[CREATE PLAN] HEADERS: $defaultHeaders');
    debugPrint(
      '[CREATE PLAN] BODY: ${jsonEncode({"planName": planName, "programActionLinkIds": actionIds})}',
    );
    final response = await http.post(
      uri,
      headers: defaultHeaders,
      body: jsonEncode({
        "planName": planName,
        "programActionLinkIds": actionIds,
      }),
    );
    debugPrint('[CREATE PLAN] STATUS: ${response.statusCode}');
    debugPrint('[CREATE PLAN] RESPONSE BODY: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create plan: ${response.statusCode}');
    }
    final jsonBody = jsonDecode(response.body);
    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// DELETE
  ////////////////////////////////////////////////////////////

  Future<Plan> deletePlan(int id) async {
    final uri = Uri.parse('$baseUrl/plan/$id');
    debugPrint('[DELETE PLAN] URI: $uri');
    debugPrint('[DELETE PLAN] HEADERS: $defaultHeaders');
    final response = await http.delete(uri, headers: defaultHeaders);
    debugPrint('[DELETE PLAN] STATUS: ${response.statusCode}');
    debugPrint('[DELETE PLAN] BODY: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete plan: ${response.statusCode}');
    }
    final jsonBody = jsonDecode(response.body);
    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// RECOVER
  ////////////////////////////////////////////////////////////

  Future<Plan> recoverPlan(int id) async {
    final uri = Uri.parse('$baseUrl/plan/recover/$id');
    debugPrint('[RECOVER PLAN] URI: $uri');
    debugPrint('[RECOVER PLAN] HEADERS: $defaultHeaders');
    final response = await http.patch(uri, headers: defaultHeaders);
    debugPrint('[RECOVER PLAN] STATUS: ${response.statusCode}');
    debugPrint('[RECOVER PLAN] BODY: ${response.body}');
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to recover plan: ${response.statusCode} ${response.body}',
      );
    }
    final jsonBody = jsonDecode(response.body);
    return Plan.fromJson(jsonBody['data']);
  }

  ////////////////////////////////////////////////////////////
  /// PROGRAM ACTION LOOKUP
  ////////////////////////////////////////////////////////////

  Future<List<ProgramActionLinkProgram>> getProgramActionLinkLookup() async {
    final uri = Uri.parse('$baseUrl/program/for-plan');
    debugPrint('[GET PROGRAM ACTION LINK LOOKUP] URI: $uri');
    debugPrint('[GET PROGRAM ACTION LINK LOOKUP] HEADERS: $defaultHeaders');
    final response = await http.get(uri, headers: defaultHeaders);
    debugPrint(
      '[GET PROGRAM ACTION LINK LOOKUP] STATUS: ${response.statusCode}',
    );
    debugPrint('[GET PROGRAM ACTION LINK LOOKUP] BODY: ${response.body}');
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Failed to load program/action links: ${response.statusCode}',
      );
    }
    final jsonBody = jsonDecode(response.body);
    final list = (jsonBody['data'] as List? ?? []);
    return list.map((e) => ProgramActionLinkProgram.fromJson(e)).toList();
  }
}
