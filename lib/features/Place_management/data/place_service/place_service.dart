import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

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

final placeServiceProvider = Provider<PlaceService>((ref) {
  return PlaceService(ref.read(dioClientProvider));
});

class PlaceService {
  final Dio _dio;

  PlaceService(this._dio);

  Future<PaginatedResponse<PlaceModel>> getPlaces({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    debugPrint('[getPlaces] API REQUEST: GET /place');
    final response = await _dio.get(
      '/place',
      queryParameters: {
        'pageNumber': page.toString(),
        'pageSize': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'searchText': search,
      },
    );
    debugPrint('[getPlaces] Status: ${response.statusCode}');
    debugPrint('[getPlaces] Body: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to load places: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
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
    debugPrint('[getPlaceById] API REQUEST: GET /place/$id');
    final response = await _dio.get('/place/$id');
    debugPrint('[getPlaceById] Status: ${response.statusCode}');
    debugPrint('[getPlaceById] Body: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to load place: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> createPlace(CreatePlaceRequest request) async {
    debugPrint('[createPlace] API REQUEST: POST /place');
    debugPrint('[createPlace] Payload: ${request.toJson()}');
    final response = await _dio.post('/place', data: request.toJson());
    debugPrint('[createPlace] Status: ${response.statusCode}');
    debugPrint('[createPlace] Body: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to create place: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> updatePlace(int id, UpdatePlaceRequest request) async {
    final payload = request.toJson();
    if (payload.isEmpty) {
      debugPrint('[PlaceService] update skipped, empty payload for id=$id');
      return getPlaceById(id);
    }
    debugPrint('[updatePlace] API REQUEST: PATCH /place/$id');
    debugPrint('[updatePlace] Payload: $payload');
    final response = await _dio.patch('/place/$id', data: payload);
    debugPrint('[updatePlace] Status: ${response.statusCode}');
    debugPrint('[updatePlace] Body: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to update place: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> deletePlace(int id) async {
    debugPrint('[deletePlace] API REQUEST: DELETE /place/$id');
    final response = await _dio.delete('/place/$id');
    debugPrint('[deletePlace] Status: ${response.statusCode}');
    debugPrint('[deletePlace] Body: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to delete place: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }

  Future<PlaceModel> recoverPlace(int id) async {
    debugPrint('[recoverPlace] API REQUEST: PATCH /place/recover/$id');
    final response = await _dio.patch('/place/recover/$id');
    debugPrint('[recoverPlace] Status: ${response.statusCode}');
    debugPrint('[recoverPlace] Body: ${response.data}');
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception('Failed to recover place: ${response.statusCode}');
    }
    final jsonBody = response.data as Map<String, dynamic>;
    return PlaceModel.fromJson(jsonBody['data'] as Map<String, dynamic>);
  }
}
