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
  // COUNTRY (simple list, first page only)
  // ===============================
  Future<List<CountryLookup>> getCountries() async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/country/lookup");
    debugPrint("[getCountries] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getCountries] Status: ${response.statusCode}");
    debugPrint("[getCountries] Body: ${response.body}");
    final body = _decode(response);
    final data = body['data'] as Map<String, dynamic>?;
    final List items = data?['items'] as List? ?? [];
    debugPrint("[getCountries] Fetched ${items.length} countries");
    return items.map((e) => CountryLookup.fromJson(e)).toList();
  }

  // Paginated countries
  Future<PaginatedLookupResponse<CountryLookup>> getCountriesPaginated({
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

    debugPrint('============== COUNTRY REQUEST ==============');
    debugPrint('URL: $uri');
    debugPrint('PageNumber: $pageNumber');
    debugPrint('SearchText: ${searchText ?? ''}');
    debugPrint('============================================');

    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;

    debugPrint('============== COUNTRY RESPONSE =============');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Items Count: ${(data['items'] as List? ?? []).length}');
    debugPrint('Total Pages: ${data['totalPages']}');
    debugPrint('Current Page: ${data['pageNumber']}');
    debugPrint('============================================');

    return PaginatedLookupResponse<CountryLookup>.fromJson(
      data,
      (e) => CountryLookup.fromJson(e),
    );
  }

  // ===============================
  // DIVISION 1
  // ===============================
  Future<List<DivisionOneLookup>> getDivisionOne(int countryId) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/division/one/lookup")
        .replace(
          queryParameters: {
            'CountryId': countryId.toString(),
            'PageNumber': '1',
            'SearchText': '',
            'Limit': '50',
          },
        );
    debugPrint("[getDivisionOne] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getDivisionOne] Status: ${response.statusCode}");
    debugPrint("[getDivisionOne] Body: ${response.body}");
    final body = _decode(response);
    final data = body['data'] as Map<String, dynamic>?;
    final List items = data?['items'] as List? ?? [];
    debugPrint("[getDivisionOne] Fetched ${items.length} divisions");
    return items.map((e) => DivisionOneLookup.fromJson(e)).toList();
  }

  Future<PaginatedLookupResponse<DivisionOneLookup>> getDivisionOnePaginated({
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

    debugPrint('============== DIVISION 1 REQUEST ==============');
    debugPrint('URL: $uri');
    debugPrint('CountryId: $countryId');
    debugPrint('PageNumber: $pageNumber');
    debugPrint('SearchText: ${searchText ?? ''}');
    debugPrint('=================================================');

    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;

    debugPrint('============== DIVISION 1 RESPONSE =============');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Items Count: ${(data['items'] as List? ?? []).length}');
    debugPrint('Total Pages: ${data['totalPages']}');
    debugPrint('Current Page: ${data['pageNumber']}');
    debugPrint('=================================================');

    return PaginatedLookupResponse<DivisionOneLookup>.fromJson(
      data,
      (e) => DivisionOneLookup.fromJson(e),
    );
  }

  // ===============================
  // DIVISION 2
  // ===============================
  Future<List<DivisionTwoLookup>> getDivisionTwo(int divOneId) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/division/two/lookup")
        .replace(
          queryParameters: {
            'DivisionOneId': divOneId.toString(),
            'PageNumber': '1',
            'SearchText': '',
            'Limit': '50',
          },
        );
    debugPrint("[getDivisionTwo] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getDivisionTwo] Status: ${response.statusCode}");
    debugPrint("[getDivisionTwo] Body: ${response.body}");
    final body = _decode(response);
    final data = body['data'] as Map<String, dynamic>?;
    final List items = data?['items'] as List? ?? [];
    debugPrint("[getDivisionTwo] Fetched ${items.length} divisions");
    return items.map((e) => DivisionTwoLookup.fromJson(e)).toList();
  }

  Future<PaginatedLookupResponse<DivisionTwoLookup>> getDivisionTwoPaginated({
    required int divOneId,
    int pageNumber = 1,
    String? searchText,
  }) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/division/two/lookup")
        .replace(
          queryParameters: {
            'DivisionOneId': divOneId.toString(),
            'PageNumber': pageNumber.toString(),
            'SearchText': searchText ?? '',
            'Limit': '10',
          },
        );

    debugPrint("============== DIVISION 2 REQUEST ==============");
    debugPrint("URL: $uri");
    debugPrint("DivisionOneId: $divOneId");
    debugPrint("PageNumber: $pageNumber");
    debugPrint("SearchText: ${searchText ?? ''}");
    debugPrint("=================================================");

    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;

    debugPrint("============== DIVISION 2 RESPONSE ==============");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Items Count: ${(data['items'] as List? ?? []).length}");
    debugPrint("Total Pages: ${data['totalPages']}");
    debugPrint("Current Page: ${data['pageNumber']}");
    debugPrint("=================================================");

    return PaginatedLookupResponse<DivisionTwoLookup>.fromJson(
      data,
      (e) => DivisionTwoLookup.fromJson(e),
    );
  }

  // ===============================
  // DIVISION 3
  // ===============================
  Future<List<DivisionThreeLookup>> getDivisionThree(int divTwoId) async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/division/three/lookup")
        .replace(
          queryParameters: {
            'DivisionTwoId': divTwoId.toString(),
            'PageNumber': '1',
            'SearchText': '',
            'Limit': '50',
          },
        );
    debugPrint("[getDivisionThree] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getDivisionThree] Status: ${response.statusCode}");
    debugPrint("[getDivisionThree] Body: ${response.body}");
    final body = _decode(response);
    final data = body['data'] as Map<String, dynamic>?;
    final List items = data?['items'] as List? ?? [];
    debugPrint("[getDivisionThree] Fetched ${items.length} divisions");
    return items.map((e) => DivisionThreeLookup.fromJson(e)).toList();
  }

  Future<PaginatedLookupResponse<DivisionThreeLookup>>
  getDivisionThreePaginated({
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
    debugPrint('============== DIVISION 3 REQUEST ==============');
    debugPrint('URL: $uri');
    debugPrint('DivisionTwoId: $divTwoId');
    debugPrint('PageNumber: $pageNumber');
    debugPrint('SearchText: ${searchText ?? ''}');
    debugPrint('=================================================');

    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;

    debugPrint('============== DIVISION 3 RESPONSE =============');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Items Count: ${(data['items'] as List? ?? []).length}');
    debugPrint('Total Pages: ${data['totalPages']}');
    debugPrint('Current Page: ${data['pageNumber']}');
    debugPrint('=================================================');

    return PaginatedLookupResponse<DivisionThreeLookup>.fromJson(
      data,
      (e) => DivisionThreeLookup.fromJson(e),
    );
  }

  // ===============================
  // POST OFFICES
  // ===============================
  Future<List<PostOfficeLookup>> getPostOffices({
    int? countryId,
    int? divOneId,
    int? divTwoId,
    int? divThreeId,
    int? placeId,
  }) async {
    // ✅ SAFETY GUARD (VERY IMPORTANT)
    if (countryId == null ||
        divOneId == null ||
        divTwoId == null ||
        divThreeId == null) {
      return [];
    }

    final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office/lookup').replace(
      queryParameters: {
        'CountryId': countryId.toString(),
        'DivOneId': divOneId.toString(),
        'DivTwoId': divTwoId.toString(),
        'DivThreeId': divThreeId.toString(),
        if (placeId != null) 'PlaceId': placeId.toString(),
      },
    );

    debugPrint("[getPostOffices] URL: $uri");

    final response = await http.get(uri, headers: headers);

    debugPrint("[getPostOffices] Status: ${response.statusCode}");
    debugPrint("[getPostOffices] Body: ${response.body}");

    final body = _decode(response);
    final data = body['data'] as Map<String, dynamic>?;
    final List items = data?['items'] as List? ?? [];

    return items.map((e) => PostOfficeLookup.fromJson(e)).toList();
  }

  Future<PaginatedLookupResponse<PostOfficeLookup>> getPostOfficesPaginated({
    required int countryId,
    required int divOneId,
    required int divTwoId,
    required int divThreeId,
    int? placeId,
    int pageNumber = 1,
    int limit = 10,
    String? searchText,
  }) async {
    final queryParameters = <String, String>{
      'CountryId': countryId.toString(),
      'DivOneId': divOneId.toString(),
      'DivTwoId': divTwoId.toString(),
      'DivThreeId': divThreeId.toString(),
      'PageNumber': pageNumber.toString(),
      'Limit': limit.toString(),
    };

    if (placeId != null) {
      queryParameters['PlaceId'] = placeId.toString();
    }
    if (searchText != null && searchText.isNotEmpty) {
      queryParameters['SearchText'] = searchText;
    }

    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/post-office/lookup',
    ).replace(queryParameters: queryParameters);

    debugPrint('============== POST OFFICES REQUEST ==============');
    debugPrint('URL: $uri');
    debugPrint('CountryId: $countryId');
    debugPrint('DivOneId: $divOneId');
    debugPrint('DivTwoId: $divTwoId');
    debugPrint('DivThreeId: $divThreeId');
    debugPrint('PageNumber: $pageNumber');
    debugPrint('Limit: $limit');
    debugPrint('SearchText: ${searchText ?? ''}');
    debugPrint('==================================================');

    final response = await http.get(uri, headers: headers);
    final jsonBody = _decode(response);
    final data = jsonBody['data'] as Map<String, dynamic>;

    debugPrint('============== POST OFFICES RESPONSE =============');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Items Count: ${(data['items'] as List? ?? []).length}');
    debugPrint('Total Pages: ${data['totalPages']}');
    debugPrint('Current Page: ${data['pageNumber']}');
    debugPrint('Total Count: ${data['totalCount']}');
    debugPrint('==================================================');

    return PaginatedLookupResponse<PostOfficeLookup>.fromJson(
      data,
      (e) => PostOfficeLookup.fromJson(e),
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

  // ===============================
  // ZIP CODES BY POST OFFICE IDS
  // (used for Add Place page)
  // ===============================
  Future<List<ZipCodeLookup>> getZipCodesByPostOfficeIds({
    required List<int> postOfficeIds,
  }) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/zipcodes/lookup/post-office-ids',
    ).replace(queryParameters: {'PostOfficeIds': postOfficeIds.join(',')});

    debugPrint('[getZipCodesByPostOfficeIds] URL: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('[getZipCodesByPostOfficeIds] Status: ${response.statusCode}');
    debugPrint('[getZipCodesByPostOfficeIds] Body: ${response.body}');

    final body = _decode(response);
    final List list = body['data'] ?? [];

    return list.map((e) => ZipCodeLookup.fromJson(e)).toList();
  }
}
