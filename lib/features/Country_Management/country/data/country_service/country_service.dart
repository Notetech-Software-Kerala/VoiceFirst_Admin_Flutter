import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Country_Management/country/data/models/country_model.dart';
import 'package:voice_first_admin/features/Country_Management/country/data/models/country_filter.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/paginated_response.dart';

class CountryService {
  Future<PaginatedResponse<CountryModel>> getAll(CountryFilter filter) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/country',
    ).replace(queryParameters: filter.toQueryParams());

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load countries: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
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
