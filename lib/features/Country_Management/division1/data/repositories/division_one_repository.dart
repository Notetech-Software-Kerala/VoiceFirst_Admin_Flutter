import 'package:dio/dio.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_model.dart';
import 'package:voice_first_admin/features/country_management/division1/data/models/division1_filter.dart';
import 'package:voice_first_admin/features/program_action/data/models/paginated_response.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

class DivisionOneRepository {
  final Dio _dio;

  DivisionOneRepository(this._dio);

  Future<PaginatedResponse<DivisionOneModel>> getAll(
    DivisionOneFilter filter,
  ) async {
    final response = await _dio.get(
      '/division/one',
      queryParameters: filter.toQueryParams(),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final jsonBody = response.data;
      throw Exception(
        'Failed to load division one: ${response.statusCode} - ${jsonBody?['message'] ?? response.statusMessage}',
      );
    }

    final jsonBody = response.data as Map<String, dynamic>;
    final data = jsonBody['data'];

    if (data is List) {
      final items = data
          .map((e) => DivisionOneModel.fromJson(e as Map<String, dynamic>))
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
          .map((e) => DivisionOneModel.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'],
      totalPages: data['totalPages'],
    );
  }
}

final divisionOneRepositoryProvider = Provider<DivisionOneRepository>((ref) {
  return DivisionOneRepository(ref.read(dioClientProvider));
});
