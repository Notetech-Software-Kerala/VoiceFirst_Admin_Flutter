import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user_filter_model.dart';

class UserRepository {
  final Dio _dio;
  UserRepository(this._dio);

  Future<Map<String, dynamic>> getUsers(UserFilterModel filter) async {
    try {
      debugPrint("Fetching Users: /employee");
      final response = await _dio.get(
        '/employee',
        queryParameters: filter.toQueryParams(),
      );

      debugPrint("Response Status: ${response.statusCode}");
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw "Failed to load: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error in getUsers: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createUser(Map<String, dynamic> data) async {
    try {
      debugPrint("Creating User: /employee");
      final response = await _dio.post('/employee', data: data);
      
      debugPrint("Create Status: ${response.statusCode}");
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw "Failed to create user: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error in createUser: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      debugPrint("Updating User: /employee/$id");
      final response = await _dio.patch('/employee/$id', data: data);

      debugPrint("Update Status: ${response.statusCode}");
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data as Map<String, dynamic>;
      } else {
        throw "Failed to update user: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error in updateUser: $e");
      rethrow;
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      debugPrint("Deleting User: /employee/$id");
      final response = await _dio.delete('/employee/$id');

      debugPrint("Delete Status: ${response.statusCode}");
      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw "Failed to delete user: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error in deleteUser: $e");
      rethrow;
    }
  }

  Future<void> recoverUser(int id) async {
    try {
      debugPrint("Recovering User: /employee/recover/$id");
      final response = await _dio.patch('/employee/recover/$id');

      debugPrint("Recover Status: ${response.statusCode}");
      if (response.statusCode == null || response.statusCode! < 200 || response.statusCode! >= 300) {
        throw "Failed to recover user: ${response.statusCode}";
      }
    } catch (e) {
      debugPrint("Error in recoverUser: $e");
      rethrow;
    }
  }
}
