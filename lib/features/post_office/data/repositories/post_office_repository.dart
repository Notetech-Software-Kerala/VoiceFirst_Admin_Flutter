import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:voice_first_admin/features/post_office/data/models/post_office_filter_model.dart';

class PostOfficeRepository {
  final Dio _dio;
  PostOfficeRepository(this._dio);

  Future<Map<String, dynamic>> getPostOffices(PostOfficeFilterModel filter) async {
    try {
      debugPrint("Fetching Post Offices: /post-office");
      final response = await _dio.get(
        '/post-office',
        queryParameters: filter.toQueryParams(),
      );

      debugPrint("Response Status: ${response.statusCode}");
      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Error in getPostOffices: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPostOfficeById(int id) async {
    final response = await _dio.get('/post-office/$id');
    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw "Failed to load post office details";
    }
  }

  Future<void> createPostOffice(Map<String, dynamic> data) async {
    final response = await _dio.post('/post-office', data: data);
    if (!_isSuccess(response)) {
      throw "Create failed: ${response.statusCode}";
    }
  }

  Future<void> updatePostOffice(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch('/post-office/$id', data: data);
    if (!_isSuccess(response)) {
      throw "Update failed: ${response.statusCode}";
    }
  }

  Future<void> deletePostOffice(int id) async {
    final response = await _dio.delete('/post-office/$id');
    if (!_isSuccess(response)) {
      throw "Delete failed: ${response.statusCode}";
    }
  }

  Future<List<dynamic>> getCountries() async {
    final response = await _dio.get('/country/lookup');
    if (response.statusCode == 200) {
      final json = response.data as Map<String, dynamic>;
      return json['data'] ?? [];
    }
    throw "Failed to load countries";
  }

  // --- DIVISION LOOKUPS ---
  Future<List<dynamic>> getDivisionOne(String countryId) async {
    final response = await _dio.get('/division/one/lookup/$countryId');
    if (_isSuccess(response)) {
      final json = response.data as Map<String, dynamic>;
      return json['data'] ?? [];
    }
    throw "Failed to load Division 1";
  }

  Future<List<dynamic>> getDivisionTwo(String divOneId) async {
    final response = await _dio.get('/division/two/lookup/$divOneId');
    if (_isSuccess(response)) {
      final json = response.data as Map<String, dynamic>;
      return json['data'] ?? [];
    }
    throw "Failed to load Division 2";
  }

  Future<List<dynamic>> getDivisionThree(String divTwoId) async {
    final response = await _dio.get('/division/three/lookup/$divTwoId');
    if (_isSuccess(response)) {
      final json = response.data as Map<String, dynamic>;
      return json['data'] ?? [];
    }
    throw "Failed to load Division 3";
  }

  bool _isSuccess(Response response) {
    if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
      return true;
    }
    return false;
  }
}
