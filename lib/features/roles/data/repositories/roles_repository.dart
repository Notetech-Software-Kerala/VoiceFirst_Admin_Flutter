import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import '../../models/role_model.dart';
import 'package:voice_first_admin/features/roles/models/role_filter_model.dart';

class RolesRepository {
  final Dio _dio;

  RolesRepository(this._dio);

  Future<Map<String, dynamic>> getRoles(RoleFilterModel filter) async {
    try {
      final response = await _dio.get(
        '/role',
        queryParameters: filter.toQueryParams(),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
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
      final response = await _dio.post('/role', data: role.toJson());

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw "Failed to create role: ${response.data}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateRole(RoleModel role) async {
    try {
      final response = await _dio.put('/role/${role.id}', data: role.toJson());

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw "Failed to update role: ${response.data}";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRole(String id) async {
    try {
      final response = await _dio.delete('/role/$id');

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        throw "Failed to delete role: ${response.data}";
      }
    } catch (e) {
      rethrow;
    }
  }
}

final rolesRepositoryProvider = Provider((ref) {
  return RolesRepository(ref.read(dioClientProvider));
});
