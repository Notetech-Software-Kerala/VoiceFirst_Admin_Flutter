import 'package:dio/dio.dart';
import 'package:voice_first_admin/features/country_management/division2/data/models/division2_filter.dart';
import 'package:voice_first_admin/features/country_management/division2/data/models/division_two_model.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/paginated_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

class DivisionTwoService {
  final Dio _dio;

  DivisionTwoService(this._dio);

  Future<PaginatedResponse<DivisionTwoModel>> getAll(
    DivisionTwoFilter filter,
  ) async {
    final response = await _dio.get(
      '/division/two',
      queryParameters: filter.toQueryParams(),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final jsonBody = response.data;
      throw Exception(
        'Failed to load division two: ${response.statusCode} - ${jsonBody?['message'] ?? response.statusMessage}',
      );
    }

    final jsonBody = response.data as Map<String, dynamic>;
    final data = jsonBody['data'];

    if (data is List) {
      final items = data
          .map((e) => DivisionTwoModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return PaginatedResponse(
        items: items,
        totalCount: items.length,
        pageNumber: filter.pageNumber,
        pageSize: filter.pageSize,
        totalPages: 1,
      );
    }

    return PaginatedResponse(
      items: (data['items'] as List)
          .map((e) => DivisionTwoModel.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'],
      totalPages: data['totalPages'],
    );
  }
}

final divisionTwoServiceProvider = Provider<DivisionTwoService>((ref) {
  return DivisionTwoService(ref.read(dioClientProvider));
});
