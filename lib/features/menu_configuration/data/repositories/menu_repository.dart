import 'package:dio/dio.dart';
import '../models/app_menu_model.dart';
import '../models/menu_master_model.dart';
import '../models/platform_model.dart';

class MenuRepository {
  final Dio _dio;

  MenuRepository(this._dio);

  final String _baseUrl = '/menu/app';
  final String _masterUrl = '/menu/master';
  final String _menuUrl = '/Menu';

  Future<void> createMenu(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(_menuUrl, data: payload);

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      } else {
        throw Exception('Failed to create menu: ${response.data}');
      }
    } catch (e) {
      throw Exception('Create menu failed: $e');
    }
  }

  Future<List<PlatformModel>> getPlatformLookup() async {
    try {
      final response = await _dio.get('/platform/lookup');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
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
      final queryParams = {
        if (searchBy != null) 'SearchBy': searchBy,
        if (plateFormId != null) 'PlateFormId': plateFormId,
        if (createdFromDate != null) 'CreatedFromDate': createdFromDate,
        if (createdToDate != null) 'CreatedToDate': createdToDate,
        if (updatedFromDate != null) 'UpdatedFromDate': updatedFromDate,
        if (updatedToDate != null) 'UpdatedToDate': updatedToDate,
        if (deletedFromDate != null) 'DeletedFromDate': deletedFromDate,
        if (deletedToDate != null) 'DeletedToDate': deletedToDate,
        if (sortBy != null) 'SortBy': sortBy,
        if (sortOrder != null) 'SortOrder': sortOrder,
        if (active != null) 'Active': active,
        if (deleted != null) 'Deleted': deleted,
        if (searchText != null && searchText.isNotEmpty)
          'SearchText': searchText,
        if (pageNumber != null) 'PageNumber': pageNumber,
        if (limit != null) 'Limit': limit,
      };

      final response = await _dio.get(_masterUrl, queryParameters: queryParams);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
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
      final response = await _dio.get(_baseUrl);
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = response.data as Map<String, dynamic>;
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
    final body = {
      "moveAndReorder": moveAndReorder,
      "reorders": reorders,
      "statusUpdate": statusUpdate,
    };

    try {
      print("--- MENU UPDATE REQUEST ---");
      print(body);

      final response = await _dio.patch('$_baseUrl/bulk', data: body);

      print("--- MENU UPDATE RESPONSE ---");
      print("Status: ${response.statusCode}");
      print("Body: ${response.data}");

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return;
      } else {
        String errorMessage = 'Failed to update menu';
        try {
          if (response.data is Map && response.data['message'] != null) {
            errorMessage = response.data['message'];
          }
        } catch (_) {
          errorMessage += ': ${response.data}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception && e.toString().contains("Failed to update menu")) {
        rethrow;
      } else if (e is DioException) {
        throw Exception(
          'API Error: ${e.response?.data['message'] ?? e.message}',
        );
      }
      throw Exception('Failed to update menu: $e');
    }
  }
}
