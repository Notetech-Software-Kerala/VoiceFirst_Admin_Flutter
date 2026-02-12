import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';
import '../models/place_requests.dart';

class PaginatedResponse<T> {
  final List<T> items;
  final int currentPage;
  final int pageSize;
  final int totalCount;
  final int totalPages;

  const PaginatedResponse({
    required this.items,
    required this.currentPage,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  bool get hasNextPage => currentPage < totalPages;
}

class PlaceService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;

  PlaceService({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
  });

  Future<PaginatedResponse<PlaceModel>> getPlaces({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    final uri = Uri.parse('$baseUrl/place').replace(
      queryParameters: {
        'pageNumber': page.toString(),
        'pageSize': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'searchText': search,
      },
    );

    final response = await http.get(uri, headers: defaultHeaders);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load places: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    final data = jsonBody['data'] as Map<String, dynamic>;

    return PaginatedResponse<PlaceModel>(
      items: (data['items'] as List<dynamic>? ?? [])
          .map((e) => PlaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: data['pageNumber'] as int? ?? 1,
      pageSize: data['pageSize'] as int? ?? pageSize,
      totalCount: data['totalCount'] as int? ?? 0,
      totalPages: data['totalPages'] as int? ?? 1,
    );
  }

  Future<PlaceModel> getPlaceById(int id) async {
    final uri = Uri.parse('$baseUrl/place/$id');
    final response = await http.get(uri, headers: defaultHeaders);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load place: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> createPlace(CreatePlaceRequest request) async {
    final uri = Uri.parse('$baseUrl/place');
    final response = await http.post(
      uri,
      headers: defaultHeaders,
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to create place: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> updatePlace(int id, UpdatePlaceRequest request) async {
    final payload = request.toJson();
    if (payload.isEmpty) {
      debugPrint('[PlaceService] update skipped, empty payload for id=$id');
      return getPlaceById(id);
    }

    final uri = Uri.parse('$baseUrl/place/$id');
    final response = await http.patch(
      uri,
      headers: defaultHeaders,
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to update place: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> deletePlace(int id) async {
    final uri = Uri.parse('$baseUrl/place/$id');
    final response = await http.delete(uri, headers: defaultHeaders);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to delete place: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> recoverPlace(int id) async {
    final uri = Uri.parse('$baseUrl/place/recover/$id');
    final response = await http.patch(uri, headers: defaultHeaders);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to recover place: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }
}
