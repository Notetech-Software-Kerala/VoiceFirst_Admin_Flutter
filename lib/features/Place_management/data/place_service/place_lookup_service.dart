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

    final response = await http.get(uri, headers: headers);
    final body = _decode(response);

    final List list = body['data'] ?? [];
    debugPrint("Fetched ${list.length} countries");

    return list.map((e) => CountryLookup.fromJson(e)).toList();
  }

  // ===============================
  // DIVISION 1
  // ===============================
  Future<List<DivisionOneLookup>> getDivisionOne(int countryId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/one/lookup/$countryId",
    );

    final response = await http.get(uri, headers: headers);
    final body = _decode(response);

    final List list = body['data'] ?? [];
    debugPrint("Fetched ${list.length} divisions");

    return list.map((e) => DivisionOneLookup.fromJson(e)).toList();
  }

  // ===============================
  // DIVISION 2
  // ===============================
  Future<List<DivisionTwoLookup>> getDivisionTwo(int divOneId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/two/lookup/$divOneId",
    );
    debugPrint("DIV2 URL -> $uri");

    final response = await http.get(uri, headers: headers);
    debugPrint("DIV2 STATUS -> ${response.statusCode}");
    debugPrint("DIV2 BODY -> ${response.body}");

    final body = _decode(response);

    final List list = body['data'] ?? [];
    debugPrint("Fetched ${list.length} divisions");

    return list.map((e) => DivisionTwoLookup.fromJson(e)).toList();
  }

  // ===============================
  // DIVISION 3
  // ===============================
  Future<List<DivisionThreeLookup>> getDivisionThree(int divTwoId) async {
    final uri = Uri.parse(
      "${ApiEndpoints.baseUrl}/division/three/lookup/$divTwoId",
    );

    final response = await http.get(uri, headers: headers);
    final body = _decode(response);

    final List list = body['data'] ?? [];
    debugPrint("Fetched ${list.length} divisions");
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
  }) async {
    final uri = Uri.parse('${ApiEndpoints.baseUrl}/post-office/lookup').replace(
      queryParameters: {
        if (countryId != null) 'CountryId': countryId.toString(),
        if (divOneId != null) 'DivOneId': divOneId.toString(),
        if (divTwoId != null) 'DivTwoId': divTwoId.toString(),
        if (divThreeId != null) 'DivThreeId': divThreeId.toString(),
      },
    );

    final response = await http.get(uri, headers: headers);
    final body = _decode(response);

    final List list = body['data'] ?? [];
    debugPrint("Fetched ${list.length} post offices");
    return list.map((e) => PostOfficeLookup.fromJson(e)).toList();
  }

  // ===============================
  // ZIP CODES
  // ===============================
  Future<List<ZipCodeLookup>> getZipCodes(int postOfficeId) async {
    final uri = Uri.parse(
      '${ApiEndpoints.baseUrl}/zipcodes/lookup/$postOfficeId',
    );

    final response = await http.get(uri, headers: headers);
    final body = _decode(response);

    final List list = body['data'] ?? [];
    debugPrint("Fetched ${list.length} zip codes");
    return list.map((e) => ZipCodeLookup.fromJson(e)).toList();
  }
}
