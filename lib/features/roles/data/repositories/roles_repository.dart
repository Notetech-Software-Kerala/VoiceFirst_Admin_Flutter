import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/role_model.dart';
// import 'package:dio/dio.dart'; // Uncomment when real API is ready

class RolesRepository {
  // final Dio _dio;
  // RolesRepository(this._dio);

  // Mock data for now to "bring the looks" without crashing on missing backend
  Future<List<RoleModel>> getRoles() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate latency
    return [
      RoleModel(
        id: '1',
        name: 'Super Admin',
        allLocationAccess: true,
        allIssueAccess: true,
        permissions: [],
        status: true,
      ),
      RoleModel(
        id: '2',
        name: 'Manager',
        allLocationAccess: false,
        allIssueAccess: true,
        permissions: [],
        status: true,
      ),
    ];
  }

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
    await Future.delayed(const Duration(seconds: 1));
    // API Call: await _dio.post('/roles', data: role.toJson());
  }

  Future<void> updateRole(RoleModel role) async {
    await Future.delayed(const Duration(seconds: 1));
    // API Call: await _dio.put('/roles', data: role.toJson());
  }

  Future<void> deleteRole(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    // API Call: await _dio.delete('/roles/$id');
  }
}

final rolesRepositoryProvider = Provider((ref) => RolesRepository());
