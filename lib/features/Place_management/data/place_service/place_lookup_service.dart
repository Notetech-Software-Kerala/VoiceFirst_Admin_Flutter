import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';

class PaginatedLookupResponse<T> {
  final List<T> items;
  final int totalCount;
  final int totalPages;
  final int currentPage;

  PaginatedLookupResponse({
    required this.items,
    required this.totalCount,
    required this.totalPages,
    required this.currentPage,
  });

  factory PaginatedLookupResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedLookupResponse(
      items: (json['items'] as List? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
      currentPage: json['pageNumber'] ?? 1,
    );
  }
}

class PlaceLookupService {
  final headers = ApiEndpoints.defaultHeaders;

  /// Common decoder (enterprise practice)
  dynamic _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }
    throw Exception('API Error: ${response.statusCode}');
  }

  // ===============================
  // COUNTRY (Paginated)
  // ===============================
  Future<PaginatedLookupResponse<CountryLookup>> getCountries({
    int pageNumber = 1,
    String? searchText,
  }) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/country/lookup").replace(
      queryParameters: {
        'PageNumber': pageNumber.toString(),
        'SearchText': searchText ?? '',
        'Limit': '10',
      },
    );
    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;
    return PaginatedLookupResponse<CountryLookup>.fromJson(
      data,
      (e) => CountryLookup.fromJson(e),
    );
  }

  // ===============================
  // DIVISION 1 (Paginated)
  // ===============================
  Future<PaginatedLookupResponse<DivisionOneLookup>> getDivisionOne({
    required int countryId,
    int pageNumber = 1,
    String? searchText,
  }) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/division/one/lookup")
        .replace(
          queryParameters: {
            'CountryId': countryId.toString(),
            'PageNumber': pageNumber.toString(),
            'SearchText': searchText ?? '',
            'Limit': '10',
          },
        );
    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;
    return PaginatedLookupResponse<DivisionOneLookup>.fromJson(
      data,
      (e) => DivisionOneLookup.fromJson(e),
    );
  }

  Future<PaginatedLookupResponse<DivisionTwoLookup>> getDivisionTwo({
    required int divOneId,
    int pageNumber = 1,
    String? searchText,
  }) async {
    final queryParams = {
      'DivisionOneId': divOneId.toString(),
      'PageNumber': pageNumber.toString(),
      'SearchText': searchText ?? '',
      'Limit': '10',
    };

    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/two/lookup",
    ).replace(queryParameters: queryParams);

    // ===========================
    // 🔍 DEBUG LOGS (REQUEST)
    // ===========================
    debugPrint("============== DIVISION 2 REQUEST ==============");
    debugPrint("URL: $uri");
    debugPrint("DivisionOneId: $divOneId");
    debugPrint("PageNumber: $pageNumber");
    debugPrint("SearchText: ${searchText ?? ''}");
    debugPrint("=================================================");

    final response = await http.get(uri, headers: headers);

    // ===========================
    // 🔍 DEBUG LOGS (RESPONSE)
    // ===========================
    debugPrint("============== DIVISION 2 RESPONSE ==============");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Raw Body: ${response.body}");
    debugPrint("=================================================");

    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;

    debugPrint("Parsed Data: $data");
    debugPrint("Items Count: ${data['items']?.length}");
    debugPrint("Total Pages: ${data['totalPages']}");
    debugPrint("=================================================");

    return PaginatedLookupResponse<DivisionTwoLookup>.fromJson(
      data,
      (e) => DivisionTwoLookup.fromJson(e),
    );
  }

  // ===============================
  // DIVISION 3 (Paginated)
  // ===============================
  Future<PaginatedLookupResponse<DivisionThreeLookup>> getDivisionThree({
    required int divTwoId,
    int pageNumber = 1,
    String? searchText,
  }) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/division/three/lookup")
        .replace(
          queryParameters: {
            'DivisionTwoId': divTwoId.toString(),
            'PageNumber': pageNumber.toString(),
            'SearchText': searchText ?? '',
            'Limit': '10',
          },
        );
    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;
    return PaginatedLookupResponse<DivisionThreeLookup>.fromJson(
      data,
      (e) => DivisionThreeLookup.fromJson(e),
    );
  }

  Future<PaginatedLookupResponse<PostOfficeLookup>> getPostOffices({
    required int countryId,
    required int divOneId,
    required int divTwoId,
    required int divThreeId,
    int pageNumber = 1,
    int limit = 10,
    String? searchText,
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office/lookup').replace(
      queryParameters: {
        'CountryId': countryId.toString(),
        'DivOneId': divOneId.toString(),
        'DivTwoId': divTwoId.toString(),
        'DivThreeId': divThreeId.toString(),
        'PageNumber': pageNumber.toString(),
        'Limit': limit.toString(),
        if (searchText != null && searchText.isNotEmpty)
          'SearchText': searchText,
      },
    );

    final response = await http.get(uri, headers: headers);
    final body = _decode(response);

    // final data = body['data'];
    final data = body['data'] as Map<String, dynamic>;

    return PaginatedLookupResponse<PostOfficeLookup>(
      items: (data['items'] as List)
          .map((e) => PostOfficeLookup.fromJson(e))
          .toList(),
      totalCount: data['totalCount'],
      totalPages: data['totalPages'],
      currentPage: data['pageNumber'],
    );
  }

  // ===============================
  // UNLINKED ZIP CODES (NEW API)
  // ===============================
  Future<List<ZipCodeLookup>> getUnlinkedZipCodes({
    required List<int> postOfficeIds,
    required int placeId,
  }) async {
    final uri =
        Uri.parse(
          '${ApiEndpoints.baseUrl}/zipcodes/lookup/post-office-ids',
        ).replace(
          queryParameters: {
            'PostOfficeIds': postOfficeIds.join(','),
            'PlaceId': placeId.toString(),
          },
        );

    debugPrint('[getUnlinkedZipCodes] URL: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('[getUnlinkedZipCodes] Status: ${response.statusCode}');
    debugPrint('[getUnlinkedZipCodes] Body: ${response.body}');

    final body = _decode(response);
    final List list = body['data'] ?? [];

    return list.map((e) => ZipCodeLookup.fromJson(e)).toList();
  }
}
