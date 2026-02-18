import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Country_Management/division1/models/division1_model.dart';
import 'package:voice_first_admin/features/Country_Management/division1/models/division1_filter.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';

class DivisionOneService {
  Future<PaginatedResponse<DivisionOneModel>> getAll(
    int countryId,
    DivisionOneFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/division/one',
    ).replace(queryParameters: filter.toQueryParams(countryId));

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load division one: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
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
