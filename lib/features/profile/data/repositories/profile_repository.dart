import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:voice_first_admin/core/network/dio_client.dart';
import '../models/user_profile_model.dart';
import '../models/update_profile_request.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfileModel> getMyProfile() async {
    final response = await _dio.get('/users/me');

    if (response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final data = response.data['data'] as Map<String, dynamic>;
      return UserProfileModel.fromJson(data);
    }

    throw Exception('Failed to load profile: ${response.statusCode}');
  }

  Future<void> updateProfile(UpdateProfileRequest request) async {
    try {
      print('Sending profile update: ${request.toJson()}');
      final response = await _dio.patch('/users/me', data: request.toJson());

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        final message = response.data?['message'] ?? 'Failed to update profile';
        throw Exception(message);
      }
    } on DioException catch (e) {
      print(
        'DioException in updateProfile: ${e.response?.statusCode} - ${e.response?.data}',
      );
      if (e.response?.data != null && e.response!.data is Map) {
        final data = e.response!.data as Map<String, dynamic>;

        // Handle {"message": ["error 1", "error 2"]} format (common validation error format)
        if (data['message'] is List) {
          final msgs = (data['message'] as List).whereType<String>().toList();
          throw Exception(msgs.join(', '));
        }

        // Handle {"message": "string error"} format
        if (data['message'] != null) {
          throw Exception(data['message'].toString());
        }
      }

      throw Exception('Server error: ${e.response?.statusCode ?? e.message}');
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.read(dioClientProvider));
});
