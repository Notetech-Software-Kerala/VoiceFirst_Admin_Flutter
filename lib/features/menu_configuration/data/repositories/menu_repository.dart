import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import '../models/app_menu_model.dart';
import '../models/menu_master_model.dart';
import '../models/platform_model.dart';

class MenuRepository {
  final String _baseUrl = '${ApiEndpoints.baseUrl}/menu/app';
  final String _masterUrl = '${ApiEndpoints.baseUrl}/menu/master';
  final String _menuUrl = '${ApiEndpoints.baseUrl}/Menu';

  Future<void> createMenu(Map<String, dynamic> payload) async {
    try {
      const storage = FlutterSecureStorage();
      final accessToken = await storage.read(key: 'access_token');

      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

      final response = await http.post(
        Uri.parse(_menuUrl),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create menu: ${response.body}');
      }
    } catch (e) {
      throw Exception('Create menu failed: $e');
    }
  }

  Future<List<PlatformModel>> getPlatformLookup() async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/platform/lookup');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'] ?? [];
        return data.map((e) => PlatformModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load platforms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load platforms: $e');
    }
  }

  Future<PaginatedMenuMasterResponse> getMenuMaster({
    String? searchBy,
    int? plateFormId,
    String? createdFromDate,
    String? createdToDate,
    String? updatedFromDate,
    String? updatedToDate,
    String? deletedFromDate,
    String? deletedToDate,
    String? sortBy,
    String? sortOrder,
    bool? active,
    bool? deleted,
    String? searchText,
    int? pageNumber,
    int? limit,
  }) async {
    try {
      final uri = Uri.parse(_masterUrl).replace(
        queryParameters: {
          if (searchBy != null) 'SearchBy': searchBy,
          if (plateFormId != null) 'PlateFormId': plateFormId.toString(),
          if (createdFromDate != null) 'CreatedFromDate': createdFromDate,
          if (createdToDate != null) 'CreatedToDate': createdToDate,
          if (updatedFromDate != null) 'UpdatedFromDate': updatedFromDate,
          if (updatedToDate != null) 'UpdatedToDate': updatedToDate,
          if (deletedFromDate != null) 'DeletedFromDate': deletedFromDate,
          if (deletedToDate != null) 'DeletedToDate': deletedToDate,
          if (sortBy != null) 'SortBy': sortBy,
          if (sortOrder != null) 'SortOrder': sortOrder,
          if (active != null) 'Active': active.toString(),
          if (deleted != null) 'Deleted': deleted.toString(),
          if (searchText != null && searchText.isNotEmpty)
            'SearchText': searchText,
          if (pageNumber != null) 'PageNumber': pageNumber.toString(),
          if (limit != null) 'Limit': limit.toString(),
        },
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        return PaginatedMenuMasterResponse.fromJson(body);
      } else {
        throw Exception('Failed to load menu master: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load menu master: $e');
    }
  }

  Future<List<AppMenuModel>> getAppMenu() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];
        final List<AppMenuModel> menuItems = data
            .map((e) => AppMenuModel.fromJson(e))
            .toList();
        return menuItems;
      } else {
        throw Exception('Failed to load menu: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load menu: $e');
    }
  }

  Future<void> updateMenuBulk({
    required List<Map<String, dynamic>> moveAndReorder,
    required List<Map<String, dynamic>> reorders,
    required List<Map<String, dynamic>> statusUpdate,
  }) async {
    final url = Uri.parse('$_baseUrl/bulk');
    final body = jsonEncode({
      "moveAndReorder": moveAndReorder,
      "reorders": reorders,
      "statusUpdate": statusUpdate,
    });

    try {
      print("--- MENU UPDATE REQUEST ---");
      print(body);

      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print("--- MENU UPDATE RESPONSE ---");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode != 200) {
        String errorMessage = 'Failed to update menu';
        try {
          final bodyMap = jsonDecode(response.body);
          if (bodyMap['message'] != null) {
            errorMessage = bodyMap['message'];
          }
        } catch (_) {
          // Fallback to raw body if JSON decode fails
          errorMessage += ': ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception && e.toString().contains("Failed to update menu")) {
        rethrow;
      }
      throw Exception('Failed to update menu: $e');
    }
  }
}
