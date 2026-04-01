import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:voice_first_admin/features/place_management/data/models/lookup_models.dart';

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
    final itemsJson = json['items'] as List<dynamic>? ?? <dynamic>[];
    final items = itemsJson
        .map((e) => fromJsonT(e as Map<String, dynamic>))
        .toList();

    return PaginatedLookupResponse(
      items: items,
      totalCount: json['totalCount'] as int? ?? items.length,
      totalPages: json['totalPages'] as int? ?? 1,
      currentPage: json['pageNumber'] as int? ?? 1,
    );
  }
}

class PlaceLookupRepository {
  final Dio _dio;

  PlaceLookupRepository(this._dio);

  dynamic _decode(Response response) {
    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      return response.data;
    }
    debugPrint('API Error: ${response.statusCode}');
    throw Exception('API Error: ${response.statusCode}');
  }

  // COUNTRIES
  Future<List<CountryLookup>> getCountries() async {
    debugPrint('[getCountries] API REQUEST: GET /country/lookup');
    final response = await _dio.get('/country/lookup');
    debugPrint('[getCountries] Status: ${response.statusCode}');
    debugPrint('[getCountries] Body: ${response.data}');
    final body = _decode(response) as Map<String, dynamic>;
    final List items = (body['data']?['items'] as List?) ?? [];
    return items
        .map((e) => CountryLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaginatedLookupResponse<CountryLookup>> getCountriesPaginated({
    int pageNumber = 1,
    String? searchText,
    int limit = 10,
  }) async {
    debugPrint('API REQUEST: GET /country/lookup (paginated)');
    final response = await _dio.get(
      '/country/lookup',
      queryParameters: {
        'PageNumber': pageNumber.toString(),
        'SearchText': searchText ?? '',
        'Limit': limit.toString(),
      },
    );

    final jsonBody = _decode(response) as Map<String, dynamic>;
    final data = jsonBody['data'] as Map<String, dynamic>;

    return PaginatedLookupResponse<CountryLookup>.fromJson(
      data,
      (e) => CountryLookup.fromJson(e),
    );
  }

  // DIVISION ONE
  Future<List<DivisionOneLookup>> getDivisionOne(int countryId) async {
    debugPrint('[getDivisionOne] API REQUEST: GET /division/one/lookup');
    final response = await _dio.get(
      '/division/one/lookup',
      queryParameters: {
        'CountryId': countryId.toString(),
        'PageNumber': '1',
        'SearchText': '',
        'Limit': '50',
      },
    );
    final body = _decode(response) as Map<String, dynamic>;
    final List items = (body['data']?['items'] as List?) ?? [];
    return items
        .map((e) => DivisionOneLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaginatedLookupResponse<DivisionOneLookup>> getDivisionOnePaginated({
    required int countryId,
    int pageNumber = 1,
    String? searchText,
    int limit = 10,
  }) async {
    debugPrint('API REQUEST: GET /division/one/lookup (paginated)');
    final response = await _dio.get(
      '/division/one/lookup',
      queryParameters: {
        'CountryId': countryId.toString(),
        'PageNumber': pageNumber.toString(),
        'SearchText': searchText ?? '',
        'Limit': limit.toString(),
      },
    );

    final jsonBody = _decode(response) as Map<String, dynamic>;
    final data = jsonBody['data'] as Map<String, dynamic>;

    return PaginatedLookupResponse<DivisionOneLookup>.fromJson(
      data,
      (e) => DivisionOneLookup.fromJson(e),
    );
  }

  // DIVISION TWO
  Future<List<DivisionTwoLookup>> getDivisionTwo(int divOneId) async {
    debugPrint('[getDivisionTwo] API REQUEST: GET /division/two/lookup');
    final response = await _dio.get(
      '/division/two/lookup',
      queryParameters: {
        'DivisionOneId': divOneId.toString(),
        'PageNumber': '1',
        'SearchText': '',
        'Limit': '50',
      },
    );
    final body = _decode(response) as Map<String, dynamic>;
    final List items = (body['data']?['items'] as List?) ?? [];
    return items
        .map((e) => DivisionTwoLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaginatedLookupResponse<DivisionTwoLookup>> getDivisionTwoPaginated({
    required int divOneId,
    int pageNumber = 1,
    String? searchText,
    int limit = 10,
  }) async {
    debugPrint('API REQUEST: GET /division/two/lookup (paginated)');
    final response = await _dio.get(
      '/division/two/lookup',
      queryParameters: {
        'DivisionOneId': divOneId.toString(),
        'PageNumber': pageNumber.toString(),
        'SearchText': searchText ?? '',
        'Limit': limit.toString(),
      },
    );

    final jsonBody = _decode(response) as Map<String, dynamic>;
    final data = jsonBody['data'] as Map<String, dynamic>;

    return PaginatedLookupResponse<DivisionTwoLookup>.fromJson(
      data,
      (e) => DivisionTwoLookup.fromJson(e),
    );
  }

  // DIVISION THREE
  Future<List<DivisionThreeLookup>> getDivisionThree(int divTwoId) async {
    debugPrint('[getDivisionThree] API REQUEST: GET /division/three/lookup');
    final response = await _dio.get(
      '/division/three/lookup',
      queryParameters: {
        'DivisionTwoId': divTwoId.toString(),
        'PageNumber': '1',
        'SearchText': '',
        'Limit': '50',
      },
    );
    final body = _decode(response) as Map<String, dynamic>;
    final List items = (body['data']?['items'] as List?) ?? [];
    return items
        .map((e) => DivisionThreeLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PaginatedLookupResponse<DivisionThreeLookup>>
  getDivisionThreePaginated({
    required int divTwoId,
    int pageNumber = 1,
    String? searchText,
    int limit = 10,
  }) async {
    debugPrint('API REQUEST: GET /division/three/lookup (paginated)');
    final response = await _dio.get(
      '/division/three/lookup',
      queryParameters: {
        'DivisionTwoId': divTwoId.toString(),
        'PageNumber': pageNumber.toString(),
        'SearchText': searchText ?? '',
        'Limit': limit.toString(),
      },
    );

    final jsonBody = _decode(response) as Map<String, dynamic>;
    final data = jsonBody['data'] as Map<String, dynamic>;

    return PaginatedLookupResponse<DivisionThreeLookup>.fromJson(
      data,
      (e) => DivisionThreeLookup.fromJson(e),
    );
  }

  // POST OFFICES
  Future<List<PostOfficeLookup>> getPostOffices({
    int? countryId,
    int? divOneId,
    int? divTwoId,
    int? divThreeId,
    int? placeId,
  }) async {
    if (countryId == null ||
        divOneId == null ||
        divTwoId == null ||
        divThreeId == null) {
      return [];
    }

    debugPrint('[getPostOffices] API REQUEST: GET /post-office/lookup');
    final response = await _dio.get(
      '/post-office/lookup',
      queryParameters: {
        'CountryId': countryId.toString(),
        'DivOneId': divOneId.toString(),
        'DivTwoId': divTwoId.toString(),
        'DivThreeId': divThreeId.toString(),
        if (placeId != null) 'PlaceId': placeId.toString(),
      },
    );

    final body = _decode(response) as Map<String, dynamic>;
    final List items = (body['data']?['items'] as List?) ?? [];
    return items
        .map((e) => PostOfficeLookup.fromJson(e as Map<String, dynamic>))
        .toList();
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
    debugPrint('API REQUEST: GET /post-office/lookup (paginated)');
    final queryParameters = <String, dynamic>{
      'CountryId': countryId.toString(),
      'DivOneId': divOneId.toString(),
      'DivTwoId': divTwoId.toString(),
      'DivThreeId': divThreeId.toString(),
      'PageNumber': pageNumber.toString(),
      'Limit': limit.toString(),
    };
    if (placeId != null) queryParameters['PlaceId'] = placeId.toString();
    if (searchText != null && searchText.isNotEmpty) {
      queryParameters['SearchText'] = searchText;
    }

    final response = await _dio.get(
      '/post-office/lookup',
      queryParameters: queryParameters,
    );
    final jsonBody = _decode(response) as Map<String, dynamic>;
    final data = jsonBody['data'] as Map<String, dynamic>;

    return PaginatedLookupResponse<PostOfficeLookup>.fromJson(
      data,
      (e) => PostOfficeLookup.fromJson(e),
    );
  }

  // UNLINKED ZIP CODES
  Future<List<ZipCodeLookup>> getUnlinkedZipCodes({
    required List<int> postOfficeIds,
    required int placeId,
  }) async {
    debugPrint(
      '[getUnlinkedZipCodes] API REQUEST: GET /zipcodes/lookup/post-office-ids',
    );
    final response = await _dio.get(
      '/zipcodes/lookup/post-office-ids',
      queryParameters: {
        'PostOfficeIds': postOfficeIds.join(','),
        'PlaceId': placeId.toString(),
      },
    );

    final body = _decode(response) as Map<String, dynamic>;
    final List list = body['data'] ?? [];
    return list
        .map((e) => ZipCodeLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ZIP CODES BY POST OFFICE IDS
  Future<List<ZipCodeLookup>> getZipCodesByPostOfficeIds({
    required List<int> postOfficeIds,
  }) async {
    debugPrint(
      '[getZipCodesByPostOfficeIds] API REQUEST: GET /zipcodes/lookup/post-office-ids',
    );
    final response = await _dio.get(
      '/zipcodes/lookup/post-office-ids',
      queryParameters: {'PostOfficeIds': postOfficeIds.join(',')},
    );

    final body = _decode(response) as Map<String, dynamic>;
    final List list = body['data'] ?? [];
    return list
        .map((e) => ZipCodeLookup.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
