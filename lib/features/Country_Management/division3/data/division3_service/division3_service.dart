import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Country_Management/division3/data/models/division_three_model.dart';
import 'package:voice_first_admin/features/Country_Management/division3/data/models/division3_filter.dart';
import 'package:voice_first_admin/features/Program_Action/data/models/paginated_response.dart';

class DivisionThreeService {
  Future<PaginatedResponse<DivisionThreeModel>> getAll(
    DivisionThreeFilter filter,
  ) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/division/three',
    ).replace(queryParameters: filter.toQueryParams());

    final response = await http.get(uri, headers: ApiEndpoints.defaultHeaders);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to load division three: ${response.statusCode}');
    }

    final jsonBody = jsonDecode(response.body);
    final data = jsonBody['data'];

    if (data is List) {
      final items = data
          .map((e) => DivisionThreeModel.fromJson(e as Map<String, dynamic>))
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
          .map((e) => DivisionThreeModel.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      pageNumber: data['pageNumber'],
      pageSize: data['pageSize'],
      totalPages: data['totalPages'],
    );
  }
}
