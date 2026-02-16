import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpoints.dart';
import '../models/app_menu_model.dart';

class MenuRepository {
  final String _baseUrl = '${ApiEndpoints.baseUrl}/menu/app';

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
