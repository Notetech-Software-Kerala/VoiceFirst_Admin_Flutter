import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';

// --- Lookup Item Model ---
class LookupItem {
  final int id;
  final String name;

  LookupItem({required this.id, required this.name});

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      // Handling both 'id'/'roleId'/'dialCodeId' and 'name'/'roleName'/'dialCode' etc.
      id: json['roleId'] ?? json['dialCodeId'] ?? json['id'] ?? 0,
      name: json['roleName'] ?? json['dialCode'] ?? json['name'] ?? '',
    );
  }
}

// --- Providers ---

/// Fetches Access Roles for the dropdown
final rolesLookupProvider = FutureProvider.autoDispose<List<LookupItem>>((
  ref,
) async {
  try {
    debugPrint("Fetching Roles Lookup: /role/lookup");
    final dio = ref.read(dioClientProvider);
    final response = await dio.get('/role/lookup');

    if (response.statusCode == 200) {
      final decoded = response.data;
      // Usually API responses are wrapped in a 'data' array or object
      final List<dynamic> data = decoded is Map
          ? (decoded['data'] ?? [])
          : decoded;
      return data.map((e) => LookupItem.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load roles');
    }
  } catch (e) {
    debugPrint("Error fetching Roles Lookup: $e");
    rethrow;
  }
});

/// Fetches Country Codes (Dial Codes) for the dropdown
final dialCodeLookupProvider = FutureProvider.autoDispose<List<LookupItem>>((
  ref,
) async {
  try {
    final dio = ref.read(dioClientProvider);
    final response = await dio.get(
      '/dialCode/lookup',
      queryParameters: {
        'PageNumber': '1',
        'Limit': '500', // Fetch enough for the dropdown
        // 'SearchText': '' // Can add search functionality later if needed
      },
    );
    debugPrint("Fetching Dial Code Lookup: /dialCode/lookup");

    if (response.statusCode == 200) {
      final decoded = response.data;

      // Robust extraction to handle both flat arrays and paginated objects
      List<dynamic> dataList = [];
      if (decoded is Map) {
        if (decoded.containsKey('data')) {
          final dataObj = decoded['data'];
          if (dataObj is Map && dataObj.containsKey('items')) {
            dataList = dataObj['items'] ?? [];
          } else if (dataObj is List) {
            dataList = dataObj;
          }
        } else if (decoded.containsKey('items')) {
          dataList = decoded['items'] ?? [];
        }
      } else if (decoded is List) {
        dataList = decoded;
      }

      // Dial codes often need a "+" prefix if not present, but let's assume API is clean
      // or we handle format in the UI.
      return dataList.map((e) {
        final item = LookupItem.fromJson(e);
        // Ensure dial codes have the plus symbol for explicit UI
        final name = item.name.startsWith('+') ? item.name : '+${item.name}';
        return LookupItem(id: item.id, name: name);
      }).toList();
    } else {
      throw Exception('Failed to load dial codes');
    }
  } catch (e) {
    debugPrint("Error fetching Dial Code Lookup: $e");
    rethrow;
  }
});
