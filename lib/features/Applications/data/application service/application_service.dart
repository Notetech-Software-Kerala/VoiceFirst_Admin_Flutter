import 'package:dio/dio.dart';
import '../models/application_model.dart';

class ApplicationService {
  static const _path = '/platform/lookup';

  final Dio _dio;
  ApplicationService(this._dio);

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
