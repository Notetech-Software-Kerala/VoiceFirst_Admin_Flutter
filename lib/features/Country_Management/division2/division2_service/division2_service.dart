import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Country_Management/division2/models/division2_filter.dart';
import 'package:voice_first_admin/features/Country_Management/division2/models/division_two_model.dart';
import 'package:voice_first_admin/features/Program_Action/models/paginated_response.dart';

class DivisionTwoService {
  Future<PaginatedResponse<DivisionTwoModel>> getAll(
    DivisionTwoFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/division/two',
    ).replace(queryParameters: filter.toQueryParams());

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load division two: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
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
