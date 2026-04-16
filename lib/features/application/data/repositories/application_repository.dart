import 'package:dio/dio.dart';
import 'package:voice_first_admin/features/application/data/models/application_model.dart';

class ApplicationRepository {
  static const _path = '/platform/lookup';

  final Dio _dio;
  ApplicationRepository(this._dio);

  Future<List<ApplicationModel>> getAll() async {
    final response = await _dio.get(_path);

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      final jsonBody = response.data;
      throw Exception(
        'Failed to load applications: ${response.statusCode} - ${jsonBody?['message'] ?? response.statusMessage}',
      );
    }

    final body = response.data as Map<String, dynamic>;
    final list = body['data'] as List;

    return list.map((e) => ApplicationModel.fromJson(e)).toList();
  }
}
