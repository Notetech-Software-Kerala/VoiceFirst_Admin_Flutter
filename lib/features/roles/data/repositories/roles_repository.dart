import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:voice_first_admin/core/config/api_endpints.dart';
import 'package:voice_first_admin/features/roles/models/role_filter_model.dart';
// import 'package:dio/dio.dart'; // Uncomment when real API is ready

class RolesRepository {
  // final Dio _dio;
  // RolesRepository(this._dio);

  Future<Map<String, dynamic>> getRoles(RoleFilterModel filter) async {
    try {
      final uri = Uri.parse(
        '${ApiEndpoints.baseUrl}/role',
      ).replace(queryParameters: filter.toQueryParams());

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw "Failed to load roles: ${response.statusCode}";
      }
    } catch (e) {
      rethrow;
    }
  }

  // Keeping this mock for now as we don't have an endpoint for Programs yet
  Future<List<ProgramModel>> getPrograms() async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      ProgramModel(
        id: 'p1',
        label: 'User Management',
        create: true,
        update: true,
        view: true,
        delete: true,
      ),
      ProgramModel(
        id: 'p2',
        label: 'Reports',
        view: true,
        download: true,
        email: true,
      ),
      ProgramModel(id: 'p3', label: 'Billing', view: true),
    ];
  }

  Future<void> createRole(RoleModel role) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/role');
      final response = await http.post(
        uri,
        headers: ApiEndpoints.defaultHeaders,
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw "Failed to create role: ${response.body}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRole(RoleModel role) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/role/${role.id}');
      final response = await http.put(
        uri,
        headers: ApiEndpoints.defaultHeaders,
        body: jsonEncode(role.toJson()),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw "Failed to update role: ${response.body}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRole(String id) async {
    try {
      final uri = Uri.parse('${ApiEndpoints.baseUrl}/role/$id');
      final response = await http.delete(uri);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw "Failed to delete role: ${response.body}";
      }
    } catch (e) {
      rethrow;
    }
  }
}

final rolesRepositoryProvider = Provider((ref) => RolesRepository());
