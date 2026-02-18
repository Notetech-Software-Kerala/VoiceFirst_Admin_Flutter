import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import 'package:voice_first_admin/features/Place_management/data/models/lookup_models.dart';

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
  // COUNTRY
  // ===============================
  Future<List<CountryLookup>> getCountries() async {
    final uri = Uri.parse("${ApiEndpoints.baseUrl}/country/lookup");
    debugPrint("[getCountries] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getCountries] Status: ${response.statusCode}");
    debugPrint("[getCountries] Body: ${response.body}");
    final body = _decode(response);
    final List list = body['data'] ?? [];
    debugPrint("[getCountries] Fetched ${list.length} countries");
    return list.map((e) => CountryLookup.fromJson(e)).toList();
  }

  // ===============================
  // DIVISION 1
  // ===============================
  Future<List<DivisionOneLookup>> getDivisionOne(int countryId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/one/lookup/$countryId",
    );
    debugPrint("[getDivisionOne] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getDivisionOne] Status: ${response.statusCode}");
    debugPrint("[getDivisionOne] Body: ${response.body}");
    final body = _decode(response);
    final List list = body['data'] ?? [];
    debugPrint("[getDivisionOne] Fetched ${list.length} divisions");
    return list.map((e) => DivisionOneLookup.fromJson(e)).toList();
  }

  // ===============================
  // DIVISION 2
  // ===============================
  Future<List<DivisionTwoLookup>> getDivisionTwo(int divOneId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/two/lookup/$divOneId",
    );
    debugPrint("[getDivisionTwo] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getDivisionTwo] Status: ${response.statusCode}");
    debugPrint("[getDivisionTwo] Body: ${response.body}");
    final body = _decode(response);
    final List list = body['data'] ?? [];
    debugPrint("[getDivisionTwo] Fetched ${list.length} divisions");
    return list.map((e) => DivisionTwoLookup.fromJson(e)).toList();
  }

  // ===============================
  // DIVISION 3
  // ===============================
  Future<List<DivisionThreeLookup>> getDivisionThree(int divTwoId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/three/lookup/$divTwoId",
    );
    debugPrint("[getDivisionThree] URL: $uri");
    final response = await http.get(uri, headers: headers);
    debugPrint("[getDivisionThree] Status: ${response.statusCode}");
    debugPrint("[getDivisionThree] Body: ${response.body}");
    final body = _decode(response);
    final List list = body['data'] ?? [];
    debugPrint("[getDivisionThree] Fetched ${list.length} divisions");
    return list.map((e) => DivisionThreeLookup.fromJson(e)).toList();
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

    final List list = body['data'] ?? [];

    return list.map((e) => PostOfficeLookup.fromJson(e)).toList();
  }
}
