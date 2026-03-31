import 'package:dio/dio.dart';
import 'package:voice_first_admin/features/Country_Management/country/data/models/country_model.dart';
import 'package:voice_first_admin/features/Country_Management/country/data/models/country_filter.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/paginated_response.dart';

class CountryService {
  final Dio _dio;

  CountryService(this._dio);

  Future<PaginatedResponse<CountryModel>> getAll(CountryFilter filter) async {
    final response = await _dio.get(
      '/country',
      queryParameters: filter.toQueryParams(),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final jsonBody = response.data;
      throw Exception(
        'Failed to load countries: ${response.statusCode} - ${jsonBody?['message'] ?? response.statusMessage}',
      );
    }

    final jsonBody = response.data as Map<String, dynamic>;
    final data = jsonBody['data'];

    // Some endpoints may return a plain list instead of paginated object
    if (data is List) {
      final items = data
          .map((e) => CountryModel.fromJson(e as Map<String, dynamic>))
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
          .map((e) => CountryModel.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'],
      totalPages: data['totalPages'],
    );
  }
}
